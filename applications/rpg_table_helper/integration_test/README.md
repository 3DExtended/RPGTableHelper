# Flutter integration tests (SignalR E2E)

These tests run against a **real** ASP.NET Core API on your Mac (iOS Simulator only; use `127.0.0.1`).

The helper endpoint `/e2e/signalr-test-jwt` is enabled only when `ASPNETCORE_ENVIRONMENT` is **`LocalSignalRE2E`** or **`E2ETest`** (the latter is used by xUnit `WebApplicationFactory`, not by `dotnet run`).

## One-command run

From the repository root:

```bash
./scripts/run_flutter_signalr_e2e.sh
```

This builds the WebApi, starts it with **`LocalSignalRE2E`** (local `maindb2.db`, migrations, dev JWT options), **`--no-launch-profile`** (so `launchSettings.json` does not force `Development`), runs from the WebApi project folder, waits until port 5012 is open, runs `flutter test integration_test/signalr_e2e_test.dart` with `--dart-define=API_BASE_URL=http://127.0.0.1:5012/`, then stops the API. (The multi-simulator test lives in `signalr_multi_client_e2e_test.dart` and is only run via `run_flutter_multi_sim_e2e.sh`.)

Optional: `IOS_DEVICE` passes `-d` to Flutter (see `flutter devices`).

## Parallel: three iPad Simulators (DM + two players)

Runs **three** `flutter test` processes (one per booted **iPad** simulator), each with `E2E_ROLE=dm|player1|player2`. Uses `/e2e/multi-client/*` to seed users/campaign and coordinate barriers so the DM registers the game before players rejoin groups, then asserts both players receive `pingFromDm`.

The script **`POST`s `/e2e/multi-client/reset` once** before Flutter starts. The Dart test **must not** call that reset in every process: if a player resets after the DM set `dmGameRegistered`, the in-memory coordinator clears and everyone deadlocks (DM waits for two players; players wait forever for the DM flag).

**Build ordering:** Xcode builds are **serialized** (DM → player1 → player2). Running three `flutter test` builds at once hits “concurrent builds” and can embed the **wrong** `E2E_ROLE` in a shared artifact, so every client acts like a player and the DM never registers. After each build finishes, all three tests run **concurrently** (DM waits on the server barrier while players catch up).

```bash
bash ./scripts/run_flutter_multi_sim_e2e.sh
```

Prefer `bash` or `./scripts/run_flutter_multi_sim_e2e.sh` over `sh`, which can enable POSIX mode and break bash features.

**Manual multi-sim (no script):** with the API up, run `curl -s -X POST http://127.0.0.1:5012/e2e/multi-client/reset` **once**, then start three `flutter test integration_test/signalr_multi_client_e2e_test.dart` processes with `E2E_ROLE` and `--dart-define=API_BASE_URL=…` (do not repeat `reset` per process).

Optional: `SIM_UDID_DM`, `SIM_UDID_PLAYER1`, `SIM_UDID_PLAYER2` to pin devices; `XCODE_WAIT_MAX_SEC` (default 600) caps how long we wait for each “Xcode build done” line in the logs.

While tests run, the script **streams** Flutter output to the terminal with `[dm]`, `[p1]`, and `[p2]` line prefixes (and still writes `dm.log` / `player1.log` / `player2.log`). Set **`MULTI_SIM_FOLLOW=0`** to disable live streaming (log files only).

The WebApi process logs to **`api.log`** in the same temp directory by default (so SignalR lines do not mix with the scripted “what step is this?” output). Set **`MULTI_SIM_API_LOG_TO_STDOUT=1`** if you want ASP.NET logs on the terminal.

## Manual

Terminal 1 (from `applications/RPGTableHelper.WebApi` so SQLite `maindb2.db` is next to the project):

```bash
export ASPNETCORE_ENVIRONMENT=LocalSignalRE2E
export ASPNETCORE_URLS=http://127.0.0.1:5012
dotnet run --no-launch-profile
```

Terminal 2 (example):

```bash
cd applications/rpg_table_helper
flutter test integration_test/signalr_e2e_test.dart -d <ios_simulator_id> --dart-define=API_BASE_URL=http://127.0.0.1:5012/
```
