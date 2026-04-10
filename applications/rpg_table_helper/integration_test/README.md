# Flutter integration tests (SignalR E2E)

These tests run against a **real** ASP.NET Core API on your Mac (iOS Simulator only; use `127.0.0.1`).

The helper endpoint `/e2e/signalr-test-jwt` is enabled only when `ASPNETCORE_ENVIRONMENT` is **`LocalSignalRE2E`** or **`E2ETest`** (the latter is used by xUnit `WebApplicationFactory`, not by `dotnet run`).

## One-command run

From the repository root:

```bash
./scripts/run_flutter_signalr_e2e.sh
```

This builds the WebApi, starts it with **`LocalSignalRE2E`** (local `maindb2.db`, migrations, dev JWT options), **`--no-launch-profile`** (so `launchSettings.json` does not force `Development`), runs from the WebApi project folder, waits until port 5012 is open, runs `flutter test integration_test` with `--dart-define=API_BASE_URL=http://127.0.0.1:5012/`, then stops the API.

Optional: `IOS_DEVICE` passes `-d` to Flutter (see `flutter devices`).

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
flutter test integration_test -d <ios_simulator_id> --dart-define=API_BASE_URL=http://127.0.0.1:5012/
```
