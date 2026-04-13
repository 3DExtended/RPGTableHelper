#!/usr/bin/env bash
# Starts WebApi (LocalSignalRE2E), resets multi-client E2E state, boots three iPad Simulators,
# runs three Flutter integration tests in parallel (DM + player1 + player2), then tears down the API.
#
# Use `bash ./scripts/run_flutter_multi_sim_e2e.sh` or `./scripts/run_flutter_multi_sim_e2e.sh`.
# Running via `sh` forces POSIX mode and breaks bash-only features; we re-exec with bash when needed.
if [ -z "${BASH_VERSION:-}" ]; then
  exec /usr/bin/env bash "$0" "$@"
fi
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-5012}"
API_URL="http://127.0.0.1:${PORT}/"
WEBAPI_PROJ="${ROOT}/applications/RPGTableHelper.WebApi/RPGTableHelper.WebApi.csproj"
WEBAPI_DIR="$(dirname "${WEBAPI_PROJ}")"
FLUTTER_DIR="${ROOT}/applications/rpg_table_helper"
API_START_TIMEOUT_SEC="${API_START_TIMEOUT_SEC:-60}"
FLUTTER_TEST_TIMEOUT="${FLUTTER_TEST_TIMEOUT:-900s}"
SIMULATOR_WAIT_SEC="${SIMULATOR_WAIT_SEC:-180}"
MULTI_LOG_DIR="${MULTI_LOG_DIR:-}"
REQUIRED_IPADS="${REQUIRED_IPADS:-3}"

if [[ -z "${MULTI_LOG_DIR}" ]]; then
  MULTI_LOG_DIR="$(mktemp -d "${TMPDIR:-/tmp}/rpg_multi_sim_e2e.XXXXXX")"
fi

echo "Multi-sim E2E logs: ${MULTI_LOG_DIR}"

# 1 = stream each flutter run to the terminal (with tags) while also writing log files.
# 0 = write logs only (quieter; good for CI).
MULTI_SIM_FOLLOW="${MULTI_SIM_FOLLOW:-1}"

# 0 = send WebApi (dotnet) stdout/stderr to api.log so SignalR/API lines do not mix with orchestration.
# 1 = show API logs on the terminal (noisy).
MULTI_SIM_API_LOG_TO_STDOUT="${MULTI_SIM_API_LOG_TO_STDOUT:-0}"

# While waiting on long steps (especially the three parallel flutter tests), print this often.
MULTI_SIM_WAIT_HEARTBEAT_SEC="${MULTI_SIM_WAIT_HEARTBEAT_SEC:-25}"

log_ts() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

free_port_if_needed() {
  local port="${1:?port}"
  if ! command -v lsof >/dev/null 2>&1; then
    return 0
  fi
  local pids=""
  pids="$(lsof -ti "tcp:${port}" 2>/dev/null || true)"
  if [[ -z "${pids}" ]]; then
    return 0
  fi
  log_ts "Port ${port} already in use; killing listener PID(s): ${pids}"
  # Kill (best effort). This is a local-dev script; lingering dotnet hosts are a common cause of false 404s.
  kill ${pids} 2>/dev/null || true
  sleep 1
}

section() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $*"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# One-line outcome from a flutter test log (PASS / FAIL / unclear).
summarize_flutter_log() {
  local role_human="$1"
  local logfile="${2:?}"
  if [[ ! -f "${logfile}" ]]; then
    echo "  ${role_human}: no log file (?)"
    return 0
  fi
  if grep -q "All tests passed" "${logfile}" 2>/dev/null; then
    echo "  ${role_human}: PASS (All tests passed)"
  elif grep -qiE "Some tests failed|Test failed|EXCEPTION CAUGHT BY FLUTTER TEST" "${logfile}" 2>/dev/null; then
    echo "  ${role_human}: FAIL — open ${logfile}"
  else
    echo "  ${role_human}: unclear (no PASS/FAIL marker) — see ${logfile}"
  fi
}

# Run flutter test in background; set LAST_FLUTTER_JOB_PID (do not use $(...) — subshell breaks $!).
LAST_FLUTTER_JOB_PID=""
launch_flutter_multi_job() {
  local role="${1:?role}"
  local udid="${2:?udid}"
  local tag="${3:?tag}"
  local logfile="${4:?log}"
  if [[ "${MULTI_SIM_FOLLOW}" == "1" ]]; then
    (
      cd "${FLUTTER_DIR}" && env "E2E_ROLE=${role}" \
        flutter test integration_test/signalr_multi_client_e2e_test.dart \
        -d "${udid}" \
        --dart-define=API_BASE_URL="${API_URL}" \
        --dart-define="E2E_ROLE=${role}" \
        --timeout="${FLUTTER_TEST_TIMEOUT}"
    ) 2>&1 | awk -v p="[${tag}] " '{ print p $0; fflush(); }' | tee "${logfile}" &
  else
    (
      cd "${FLUTTER_DIR}" && env "E2E_ROLE=${role}" \
        flutter test integration_test/signalr_multi_client_e2e_test.dart \
        -d "${udid}" \
        --dart-define=API_BASE_URL="${API_URL}" \
        --dart-define="E2E_ROLE=${role}" \
        --timeout="${FLUTTER_TEST_TIMEOUT}"
    ) > "${logfile}" 2>&1 &
  fi
  LAST_FLUTTER_JOB_PID=$!
}

ensure_n_ipad_simulators() {
  local n="${1:?count}"
  if ! command -v xcrun >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
    echo "Need xcrun (Xcode) and python3." >&2
    return 1
  fi

  python3 - "$n" <<'PY'
import json, subprocess, sys

n_need = int(sys.argv[1])

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
            if "iPad" not in d.get("name", ""):
                continue
            yield d

data = load()
sims = list(ipad_sims(data))
if len(sims) < n_need:
    print(
        f"Need at least {n_need} iPad simulators (available: {len(sims)}). Add iPad runtimes in Xcode.",
        file=sys.stderr,
    )
    sys.exit(1)

udids = []
booted = [d for d in sims if d.get("state") == "Booted"]
for d in sorted(booted, key=lambda x: x.get("name", "")):
    udids.append(d["udid"])
    if len(udids) >= n_need:
        break

shutdown = [d for d in sims if d.get("state") == "Shutdown"]
for d in sorted(shutdown, key=lambda x: x.get("name", "")):
    if len(udids) >= n_need:
        break
    udid = d["udid"]
    br = subprocess.run(
        ["xcrun", "simctl", "boot", udid],
        capture_output=True,
        text=True,
    )
    if br.returncode != 0:
        data2 = load()
        st = next((x.get("state") for x in ipad_sims(data2) if x.get("udid") == udid), None)
        if st != "Booted":
            print(br.stderr or br.stdout, file=sys.stderr)
            sys.exit(1)
    subprocess.run(
        ["xcrun", "simctl", "bootstatus", udid, "-b"],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    udids.append(udid)

if len(udids) < n_need:
    print("Could not boot enough iPad simulators.", file=sys.stderr)
    sys.exit(1)

subprocess.run(["open", "-a", "Simulator"], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

for u in udids[:n_need]:
    print(u)
PY
}

wait_for_flutter_device() {
  local udid="${1:?udid}"
  local ok=0
  for ((i = 1; i <= SIMULATOR_WAIT_SEC; i++)); do
    if flutter devices --machine 2>/dev/null | python3 -c "import json,sys; u=sys.argv[1]; d=json.load(sys.stdin); sys.exit(0 if any(x.get('id')==u for x in d) else 1)" "${udid}" 2>/dev/null; then
      ok=1
      break
    fi
    if (( i % 10 == 0 )); then
      log_ts "  still waiting for Flutter to list simulator ${udid} (${i}s / ${SIMULATOR_WAIT_SEC}s)"
    fi
    sleep 1
  done
  if [[ "${ok}" -ne 1 ]]; then
    echo "Timed out waiting for Flutter to see simulator ${udid}" >&2
    return 1
  fi
}

section "Build WebApi"
echo "Project: ${WEBAPI_PROJ}"
dotnet build "${WEBAPI_PROJ}" -v quiet

section "Start API (LocalSignalRE2E)"
echo "Base URL: ${API_URL}"
echo "SQLite:   ${WEBAPI_DIR}/maindb2.db"
if [[ "${MULTI_SIM_API_LOG_TO_STDOUT}" == "1" ]]; then
  echo "API process: logging to this terminal (MULTI_SIM_API_LOG_TO_STDOUT=1)."
else
  echo "API process: stdout/stderr → ${MULTI_LOG_DIR}/api.log (set MULTI_SIM_API_LOG_TO_STDOUT=1 to stream here)."
fi
# Ensure we don't accidentally talk to an older server instance.
free_port_if_needed "${PORT}"
# Do not use dotnet run --no-build: the API must pick up E2E controller changes or new routes return 404.
pushd "${WEBAPI_DIR}" > /dev/null
if [[ "${MULTI_SIM_API_LOG_TO_STDOUT}" == "1" ]]; then
  env ASPNETCORE_ENVIRONMENT=LocalSignalRE2E \
    ASPNETCORE_URLS="http://127.0.0.1:${PORT}" \
    dotnet run \
    --project "$(basename "${WEBAPI_PROJ}")" \
    --no-launch-profile \
    --environment LocalSignalRE2E \
    &
else
  env ASPNETCORE_ENVIRONMENT=LocalSignalRE2E \
    ASPNETCORE_URLS="http://127.0.0.1:${PORT}" \
    dotnet run \
    --project "$(basename "${WEBAPI_PROJ}")" \
    --no-launch-profile \
    --environment LocalSignalRE2E \
    > "${MULTI_LOG_DIR}/api.log" 2>&1 &
fi
API_PID=$!
popd > /dev/null

cleanup() {
  if [[ -n "${MULTI_SIM_HEARTBEAT_PID:-}" ]] && kill -0 "${MULTI_SIM_HEARTBEAT_PID}" 2>/dev/null; then
    kill "${MULTI_SIM_HEARTBEAT_PID}" 2>/dev/null || true
    wait "${MULTI_SIM_HEARTBEAT_PID}" 2>/dev/null || true
  fi
  if kill -0 "${API_PID}" 2>/dev/null; then
    echo "Stopping API (pid ${API_PID})..."
    kill "${API_PID}" 2>/dev/null || true
    wait "${API_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

log_ts "Waiting for TCP ${PORT} (max ${API_START_TIMEOUT_SEC}s)..."
up=0
for ((i = 1; i <= API_START_TIMEOUT_SEC; i++)); do
  if ! kill -0 "${API_PID}" 2>/dev/null; then
    echo "API exited before port opened." >&2
    exit 1
  fi
  if nc -z 127.0.0.1 "${PORT}" 2>/dev/null; then
    up=1
    break
  fi
  if (( i % 5 == 0 )); then
    log_ts "  port ${PORT} not open yet (${i}s / ${API_START_TIMEOUT_SEC}s), API pid=${API_PID}"
  fi
  sleep 1
done
if [[ "${up}" -ne 1 ]]; then
  echo "Timed out waiting for port ${PORT}." >&2
  exit 1
fi

if ! curl -sf --max-time 15 -o /dev/null "http://127.0.0.1:${PORT}/e2e/signalr-test-jwt"; then
  echo "Health check failed (GET /e2e/signalr-test-jwt)." >&2
  exit 1
fi
echo "Health OK (e2e JWT endpoint reachable)."

section "Reset in-memory multi-client barriers"
echo "POST /e2e/multi-client/reset (clears dmGameRegistered / playersReadded counters)."
if ! curl -sf --max-time 15 -X POST "http://127.0.0.1:${PORT}/e2e/multi-client/reset"; then
  echo "POST /e2e/multi-client/reset failed." >&2
  exit 1
fi
echo "OK."

cd "${FLUTTER_DIR}"

declare -a UDIDS
if [[ -n "${SIM_UDID_DM:-}" && -n "${SIM_UDID_PLAYER1:-}" && -n "${SIM_UDID_PLAYER2:-}" ]]; then
  UDIDS=("${SIM_UDID_DM}" "${SIM_UDID_PLAYER1}" "${SIM_UDID_PLAYER2}")
  echo "Using SIM_UDID_DM / SIM_UDID_PLAYER1 / SIM_UDID_PLAYER2"
else
  echo "Ensuring ${REQUIRED_IPADS} booted iPad simulators..."
  # Avoid mapfile / process substitution: `sh ./script.sh` uses bash in POSIX mode and rejects <(...).
  _ipad_udids_file="$(mktemp)"
  ensure_n_ipad_simulators "${REQUIRED_IPADS}" > "${_ipad_udids_file}" || exit 1
  UDIDS=()
  while IFS= read -r line || [ -n "${line}" ]; do
    [ -z "${line}" ] && continue
    UDIDS+=("${line}")
  done < "${_ipad_udids_file}"
  rm -f "${_ipad_udids_file}"
fi

if [[ "${#UDIDS[@]}" -lt 3 ]]; then
  echo "Need three simulator UDIDs (got ${#UDIDS[@]})." >&2
  exit 1
fi

section "iPad simulators (Flutter must see each device)"
for i in 0 1 2; do
  echo "  [$((i + 1))/3] ${UDIDS[$i]} — waiting for flutter devices…"
  wait_for_flutter_device "${UDIDS[$i]}" || exit 1
done
echo "All three simulators visible to Flutter."

# Three devices, but NOT three concurrent Xcode builds (shared build/ + wrong E2E_ROLE).
# Build sequentially; then all three test runs proceed (DM blocks on server barrier).
XCODE_WAIT_MAX_SEC="${XCODE_WAIT_MAX_SEC:-600}"

wait_for_xcode_build_done() {
  local logfile="${1:?log}"
  local label="${2:?label}"
  echo "  → Xcode build (${label}) — polling log for 'Xcode build done' (max ${XCODE_WAIT_MAX_SEC}s)…"
  for ((i = 1; i <= XCODE_WAIT_MAX_SEC; i++)); do
    if [[ -f "${logfile}" ]]; then
      if grep -q "Xcode build done" "${logfile}" 2>/dev/null; then
        echo "  ✓ iOS build finished (${label}). Test body runs next on that simulator."
        return 0
      fi
      if grep -qiE "xcode build failed|failed to build ios|command phase script execution failed|error:.*xcodebuild" "${logfile}" 2>/dev/null; then
        echo "Xcode/iOS build error — see ${logfile}" >&2
        return 1
      fi
    fi
    if (( i % 20 == 0 )); then
      _last="$(tail -n 1 "${logfile}" 2>/dev/null | head -c 140)"
      log_ts "  Xcode [${label}] ${i}s elapsed — tail: ${_last}"
    fi
    sleep 1
  done
  echo "Timeout waiting for 'Xcode build done' in ${logfile}" >&2
  return 1
}

section "Scenario: DM + 2 players (SignalR, signalr_multi_client_e2e_test.dart)"
echo "  One integration test per device (single POST …/reset — no per-scenario reset; avoids hang when runners desync)."
echo "  After barrier: ping → large updateRpgConfig → character→DM → pong → empty ping."
echo "  Barrier once: DM RegisterGame → POST …/sync/dm-game-registered; players wait, ReaddToSignalRGroups → POST …/sync/player-readded; DM waits for count 2."
echo "Flutter output uses tags [dm] [p1] [p2]. Full files: ${MULTI_LOG_DIR}/dm.log etc."
if [[ "${MULTI_SIM_FOLLOW}" == "1" ]]; then
  echo "Live stream: ON (MULTI_SIM_FOLLOW=0 to disable)."
else
  echo "Live stream: OFF — read log files only."
fi

section "Step A — DM runner (sequential Xcode build #1)"
echo "Device: ${UDIDS[0]}"
launch_flutter_multi_job dm "${UDIDS[0]}" dm "${MULTI_LOG_DIR}/dm.log"
PID_DM="${LAST_FLUTTER_JOB_PID}"
wait_for_xcode_build_done "${MULTI_LOG_DIR}/dm.log" "dm" || exit 1

section "Step B — Player 1 runner (sequential Xcode build #2)"
echo "Device: ${UDIDS[1]}"
launch_flutter_multi_job player1 "${UDIDS[1]}" p1 "${MULTI_LOG_DIR}/player1.log"
PID_P1="${LAST_FLUTTER_JOB_PID}"
wait_for_xcode_build_done "${MULTI_LOG_DIR}/player1.log" "player1" || exit 1

section "Step C — Player 2 runner (sequential Xcode build #3)"
echo "Device: ${UDIDS[2]}"
launch_flutter_multi_job player2 "${UDIDS[2]}" p2 "${MULTI_LOG_DIR}/player2.log"
PID_P2="${LAST_FLUTTER_JOB_PID}"
wait_for_xcode_build_done "${MULTI_LOG_DIR}/player2.log" "player2" || exit 1

section "Waiting for all three flutter test processes to exit"
log_ts "PIDs: dm=${PID_DM} player1=${PID_P1} player2=${PID_P2}"
echo "Heartbeat every ${MULTI_SIM_WAIT_HEARTBEAT_SEC}s: RUNNING + line/byte count + last ~400 bytes of log (CR→newline, each line capped ~132 chars). Bytes growing = output still flowing."
echo "DM often blocks here until both players hit the server barrier — that is normal."

MULTI_SIM_HEARTBEAT_PID=""
_flutter_heartbeat_tick() {
  echo ""
  log_ts "── flutter status ──"
  for _tuple in "dm:${PID_DM}:${MULTI_LOG_DIR}/dm.log" "p1:${PID_P1}:${MULTI_LOG_DIR}/player1.log" "p2:${PID_P2}:${MULTI_LOG_DIR}/player2.log"; do
    _tag="${_tuple%%:*}"
    _rest="${_tuple#*:}"
    _pid="${_rest%%:*}"
    _log="${_rest#*:}"
    if kill -0 "${_pid}" 2>/dev/null; then
      _lines="0"
      _bytes="0"
      if [[ -f "${_log}" ]]; then
        _lines="$(wc -l < "${_log}" 2>/dev/null | tr -d ' ')"
        _bytes="$(wc -c < "${_log}" 2>/dev/null | tr -d ' ')"
      fi
      echo "  [${_tag}] RUNNING pid=${_pid}  lines=${_lines}  bytes=${_bytes}"
      if [[ -f "${_log}" ]] && [[ "${_bytes}" -gt 0 ]]; then
        # Flutter often writes progress on one physical line with \r — tail -n 3 explodes width. Use tail -c + CR→LF + truncate.
        tail -c 450 "${_log}" 2>/dev/null | tr '\r' '\n' | grep -v '^[[:space:]]*$' | tail -n 6 | while IFS= read -r _ln || [[ -n "${_ln}" ]]; do
          if [[ -z "${_ln}" ]]; then
            continue
          fi
          if [[ "${#_ln}" -gt 132 ]]; then
            _ln="${_ln:0:129}..."
          fi
          printf '  [%s] | %s\n' "${_tag}" "${_ln}"
        done
      fi
    else
      echo "  [${_tag}] process exited (pid ${_pid} not running)"
    fi
  done
}

if [[ "${MULTI_SIM_WAIT_HEARTBEAT_SEC}" =~ ^[0-9]+$ ]] && [[ "${MULTI_SIM_WAIT_HEARTBEAT_SEC}" -gt 0 ]]; then
  _flutter_heartbeat_tick
  (
    while sleep "${MULTI_SIM_WAIT_HEARTBEAT_SEC}"; do
      log_ts "── repeat every ${MULTI_SIM_WAIT_HEARTBEAT_SEC}s ──"
      _flutter_heartbeat_tick
    done
  ) &
  MULTI_SIM_HEARTBEAT_PID=$!
else
  log_ts "Flutter wait heartbeats disabled (set MULTI_SIM_WAIT_HEARTBEAT_SEC to a positive integer to enable)."
fi

EC_DM=0
EC_P1=0
EC_P2=0
log_ts "waiting on DM flutter (pid ${PID_DM})…"
wait "${PID_DM}" || EC_DM=$?
log_ts "DM flutter finished (exit ${EC_DM}). Waiting player1 (pid ${PID_P1})…"
wait "${PID_P1}" || EC_P1=$?
log_ts "Player1 finished (exit ${EC_P1}). Waiting player2 (pid ${PID_P2})…"
wait "${PID_P2}" || EC_P2=$?
log_ts "All three flutter processes exited."

if [[ -n "${MULTI_SIM_HEARTBEAT_PID}" ]] && kill -0 "${MULTI_SIM_HEARTBEAT_PID}" 2>/dev/null; then
  kill "${MULTI_SIM_HEARTBEAT_PID}" 2>/dev/null || true
  wait "${MULTI_SIM_HEARTBEAT_PID}" 2>/dev/null || true
fi
MULTI_SIM_HEARTBEAT_PID=""

section "Outcome (parsed from flutter logs)"
echo "Process exit codes: dm=${EC_DM} player1=${EC_P1} player2=${EC_P2}"
summarize_flutter_log "DM" "${MULTI_LOG_DIR}/dm.log"
summarize_flutter_log "Player 1" "${MULTI_LOG_DIR}/player1.log"
summarize_flutter_log "Player 2" "${MULTI_LOG_DIR}/player2.log"
echo ""
echo "Full logs:"
echo "  ${MULTI_LOG_DIR}/api.log     — ASP.NET Core (WebApi)"
echo "  ${MULTI_LOG_DIR}/dm.log      — flutter test, role=dm"
echo "  ${MULTI_LOG_DIR}/player1.log — flutter test, role=player1"
echo "  ${MULTI_LOG_DIR}/player2.log — flutter test, role=player2"

if [[ "${EC_DM}" -ne 0 || "${EC_P1}" -ne 0 || "${EC_P2}" -ne 0 ]]; then
  section "Hint — last lines from logs (for debugging)"
  tail -n 18 "${MULTI_LOG_DIR}/dm.log" 2>/dev/null | sed 's/^/[dm]    /' || true
  tail -n 18 "${MULTI_LOG_DIR}/player1.log" 2>/dev/null | sed 's/^/[p1]    /' || true
  tail -n 18 "${MULTI_LOG_DIR}/player2.log" 2>/dev/null | sed 's/^/[p2]    /' || true
  echo "One or more runs failed. Exit codes: dm=${EC_DM} player1=${EC_P1} player2=${EC_P2}" >&2
  exit 1
fi

section "Done"
echo "Multi-simulator integration tests finished OK."
