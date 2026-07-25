# [slice] auth-04 — Auto-refresh: proactive timer + Chopper 401 + SSE `refreshJwt` single-flight

## Metadata

- Forge: local
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`

## What to build

Wire TokenRefresher into ongoing sessions: refresh ~5 minutes before `expiresIn`, on app resume when near/past expiry, and on REST/SSE 401 with a single retry. Ensure single-flight so concurrent callers share one refresh. On hard refresh failure mid-session, clear local tokens and navigate to `LoginScreen`. Connect the existing SSE `refreshJwt` hook.

Demoable: leave the app open past access expiry (or force short lifetime in tests) → background refresh keeps API/SSE working; forced 401 recovers once; failed refresh boots to login.

## Acceptance criteria

- [ ] Proactive refresh scheduled ~5 minutes before `expiresIn` from the auth response
- [ ] App resume triggers refresh when access is expired or within the lead window
- [ ] Chopper (or equivalent) 401 path refreshes once and retries the failed request
- [ ] SSE auth failure uses `refreshJwt` / TokenRefresher instead of reconnecting with a stale JWT only
- [ ] Concurrent refresh attempts are single-flight (one network refresh; others await result)
- [ ] Mid-session refresh failure clears tokens and navigates to `LoginScreen`
- [ ] Flutter tests cover single-flight and 401→refresh→retry behavior

## Blocked by

- auth-02
- auth-03

## User stories covered

- 3, 4, 14
