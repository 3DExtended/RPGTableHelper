#!/usr/bin/env bash
# Starts RPGTableHelper.WebApi in LocalSignalRE2E mode, runs Flutter integration_test on an iPad Simulator (tablet-first; iPhone is not fully supported), then tears down the API.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-5012}"
API_URL="http://127.0.0.1:${PORT}/"
WEBAPI_PROJ="${ROOT}/applications/RPGTableHelper.WebApi/RPGTableHelper.WebApi.csproj"
WEBAPI_DIR="$(dirname "${WEBAPI_PROJ}")"
FLUTTER_DIR="${ROOT}/applications/rpg_table_helper"
API_START_TIMEOUT_SEC="${API_START_TIMEOUT_SEC:-60}"
# Per-test timeout (dart test format: 60s, 15m, 2x, or none)
FLUTTER_TEST_TIMEOUT="${FLUTTER_TEST_TIMEOUT:-900s}"
SIMULATOR_WAIT_SEC="${SIMULATOR_WAIT_SEC:-120}"

# LocalSignalRE2E: local maindb2.db + migrations + dev Jwt fallback (see Startup.cs). E2ETest is reserved for xUnit WebApplicationFactory.

# Boot an iPad Simulator and set IOS_DEVICE so Flutter does not pick a wireless physical device or iPhone (not fully supported for this app).
ensure_ios_simulator() {
  if [[ -n "${IOS_DEVICE:-}" ]]; then
    echo "Using IOS_DEVICE=${IOS_DEVICE} (skip auto simulator boot)."
    return 0
  fi
  if ! command -v xcrun >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
    echo "Need xcrun (Xcode) and python3 to auto-boot an iPad Simulator." >&2
    return 1
  fi

  local udid
  udid="$(python3 <<'PY'
import json, subprocess, sys

def load():
    out = subprocess.check_output(["xcrun", "simctl", "list", "devices", "-j"], text=True)
    return json.loads(out)

def ipad_sims(data):
    for _rt, devs in data.get("devices", {}).items():
        if "iOS" not in _rt:
            continue
        for d in devs:
            if not d.get("isAvailable"):
                continue
            name = d.get("name", "")
            if "iPad" not in name:
                continue
            yield d

data = load()
sims = list(ipad_sims(data))
if not sims:
    print(
        "No iPad simulator found. This app targets tablet; add an iPad simulator in Xcode (Devices and Simulators) or set IOS_DEVICE to a simulator UDID.",
        file=sys.stderr,
    )
    sys.exit(1)

booted = [d for d in sims if d.get("state") == "Booted"]
if booted:
    booted.sort(key=lambda d: d.get("name", ""))
    print(booted[0]["udid"])
    sys.exit(0)

shutdown = [d for d in sims if d.get("state") == "Shutdown"]
if not shutdown:
    print("No shutdown iPad simulator available. Install an iOS runtime in Xcode.", file=sys.stderr)
    sys.exit(1)

shutdown.sort(key=lambda d: d.get("name", ""))
udid = shutdown[0]["udid"]
br = subprocess.run(
    ["xcrun", "simctl", "boot", udid],
    capture_output=True,
    text=True,
)
if br.returncode != 0:
    data2 = load()
    st = next((d.get("state") for d in ipad_sims(data2) if d.get("udid") == udid), None)
    if st != "Booted":
        print(br.stderr or br.stdout, file=sys.stderr)
        sys.exit(1)
subprocess.run(
    ["xcrun", "simctl", "bootstatus", udid, "-b"],
    check=True,
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
)
subprocess.run(["open", "-a", "Simulator"], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
# Only stdout line must be the UDID (simctl may print progress otherwise).
print(udid)
PY
)" || return 1

  # Single-line UUID (defensive: ignore any stray simctl output).
  udid="$(echo "${udid}" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | tail -1)"
  if [[ -z "${udid}" ]]; then
    echo "Could not parse simulator UDID from simctl." >&2
    return 1
  fi

  IOS_DEVICE="${udid}"
  export IOS_DEVICE
  echo "Ensured iPad Simulator is booting: ${IOS_DEVICE}"

  echo "Waiting for Flutter to see iPad simulator (max ${SIMULATOR_WAIT_SEC}s)..."
  local ok=0
  for ((i = 1; i <= SIMULATOR_WAIT_SEC; i++)); do
    if flutter devices --machine 2>/dev/null | python3 -c "import json,sys; u=sys.argv[1]; d=json.load(sys.stdin); sys.exit(0 if any(x.get('id')==u for x in d) else 1)" "${IOS_DEVICE}" 2>/dev/null; then
      ok=1
      break
    fi
    sleep 1
  done
  if [[ "${ok}" -ne 1 ]]; then
    echo "Timed out waiting for iPad simulator ${IOS_DEVICE} in flutter devices --machine." >&2
    return 1
  fi
  echo "iPad simulator ready for Flutter: ${IOS_DEVICE}"
}

echo "Building WebApi..."
dotnet build "${WEBAPI_PROJ}" -v quiet

echo "Starting API on ${API_URL}"
echo "  ASPNETCORE_ENVIRONMENT=LocalSignalRE2E (forced via dotnet --environment)"
echo "  SQLite: ${WEBAPI_DIR}/maindb2.db"

# Run from WebApi directory so SQLite path maindb2.db resolves next to the project.
# --no-launch-profile: do NOT use launchSettings.json (it forces Development + wrong URLs).
# --environment: belt-and-suspenders so the hosting environment is never wrong.
pushd "${WEBAPI_DIR}" > /dev/null
env ASPNETCORE_ENVIRONMENT=LocalSignalRE2E \
  ASPNETCORE_URLS="http://127.0.0.1:${PORT}" \
  dotnet run \
  --project "$(basename "${WEBAPI_PROJ}")" \
  --no-build \
  --no-launch-profile \
  --environment LocalSignalRE2E \
  &
API_PID=$!
popd > /dev/null

cleanup() {
  if kill -0 "${API_PID}" 2>/dev/null; then
    echo "Stopping API (pid ${API_PID})..."
    kill "${API_PID}" 2>/dev/null || true
    wait "${API_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "Waiting for API (max ${API_START_TIMEOUT_SEC}s, pid ${API_PID})..."
up=0
for ((i = 1; i <= API_START_TIMEOUT_SEC; i++)); do
  if ! kill -0 "${API_PID}" 2>/dev/null; then
    echo "API process exited before the port opened. Typical causes:" >&2
    echo "  - Old script: must use LocalSignalRE2E + --no-launch-profile (not E2ETest + launchSettings)." >&2
    echo "  - SQLite: cannot write ${WEBAPI_DIR}/maindb2.db" >&2
    echo "  - Run: dotnet run --project \"${WEBAPI_PROJ}\" --no-launch-profile --environment LocalSignalRE2E" >&2
    exit 1
  fi
  if nc -z 127.0.0.1 "${PORT}" 2>/dev/null; then
    up=1
    break
  fi
  sleep 1
done

if [[ "${up}" -ne 1 ]]; then
  echo "Timed out waiting for port ${PORT} (API still running: $(kill -0 "${API_PID}" 2>/dev/null && echo yes || echo no))." >&2
  exit 1
fi

echo "Port ${PORT} is open; probing /e2e/signalr-test-jwt ..."
if ! curl -sf --max-time 15 -o /dev/null "http://127.0.0.1:${PORT}/e2e/signalr-test-jwt"; then
  echo "Health check failed (expected HTTP 200 from /e2e/signalr-test-jwt)." >&2
  exit 1
fi

cd "${FLUTTER_DIR}"

ensure_ios_simulator

# Single-file run: do not glob `integration_test/` (multi-sim tests need E2E_ROLE).
FLUTTER_TEST_ARGS=(
  test integration_test/signalr_e2e_test.dart
  --dart-define=API_BASE_URL="${API_URL}"
  --timeout="${FLUTTER_TEST_TIMEOUT}"
)
if [[ -n "${IOS_DEVICE:-}" ]]; then
  FLUTTER_TEST_ARGS+=(-d "${IOS_DEVICE}")
fi
# Wireless / tethered iOS: Flutter may require --publish-port (set FLUTTER_PUBLISH_PORT=1).
if [[ "${FLUTTER_PUBLISH_PORT:-}" == "1" ]]; then
  FLUTTER_TEST_ARGS+=(--publish-port)
fi

echo "Running: flutter ${FLUTTER_TEST_ARGS[*]}"
echo "(Optional env: IOS_DEVICE, SIMULATOR_WAIT_SEC, FLUTTER_PUBLISH_PORT=1, FLUTTER_TEST_TIMEOUT=600s, API_START_TIMEOUT_SEC=90)"
echo "Wall-clock cap (macOS): brew install coreutils && gtimeout 1200 bash $0"

flutter "${FLUTTER_TEST_ARGS[@]}"

echo "Integration tests finished."
