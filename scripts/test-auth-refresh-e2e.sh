#!/usr/bin/env bash
# Local auth refresh E2E against a running RPGTableHelper API (LocalSignalRE2E).
# Usage: ./scripts/test-auth-refresh-e2e.sh [baseUrl]
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:5214}"
BASE_URL="${BASE_URL%/}"

echo "==> Auth refresh E2E against ${BASE_URL}"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

json_field() {
  local json="$1" field="$2"
  python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$field" <<<"$json"
}

echo "-- mint token pair via /e2e/auth-token-pair"
PAIR_HTTP=$(curl -sS -w "\n%{http_code}" "${BASE_URL}/e2e/auth-token-pair")
PAIR_BODY=$(echo "$PAIR_HTTP" | sed '$d')
PAIR_CODE=$(echo "$PAIR_HTTP" | tail -n1)
[[ "$PAIR_CODE" == "200" ]] || fail "auth-token-pair returned $PAIR_CODE: $PAIR_BODY"

ACCESS=$(json_field "$PAIR_BODY" accessToken)
REFRESH=$(json_field "$PAIR_BODY" refreshToken)
EXPIRES=$(json_field "$PAIR_BODY" expiresIn)
[[ -n "$ACCESS" && -n "$REFRESH" && -n "$EXPIRES" ]] || fail "token pair missing fields: $PAIR_BODY"
pass "minted access+refresh (expiresIn=$EXPIRES)"

echo "-- access token works on /SignIn/testlogin"
TEST_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -H "Authorization: Bearer ${ACCESS}" "${BASE_URL}/SignIn/testlogin")
[[ "$TEST_CODE" == "200" ]] || fail "testlogin with access token returned $TEST_CODE"
pass "testlogin OK"

echo "-- refresh rotates tokens"
REFRESH_HTTP=$(curl -sS -w "\n%{http_code}" -X POST "${BASE_URL}/SignIn/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH}\"}")
REFRESH_BODY=$(echo "$REFRESH_HTTP" | sed '$d')
REFRESH_CODE=$(echo "$REFRESH_HTTP" | tail -n1)
[[ "$REFRESH_CODE" == "200" ]] || fail "refresh returned $REFRESH_CODE: $REFRESH_BODY"
ACCESS2=$(json_field "$REFRESH_BODY" accessToken)
REFRESH2=$(json_field "$REFRESH_BODY" refreshToken)
[[ "$REFRESH2" != "$REFRESH" ]] || fail "refresh did not rotate refresh token"
[[ -n "$ACCESS2" ]] || fail "refresh missing accessToken"
pass "refresh rotated"

echo "-- new access token works"
TEST2_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -H "Authorization: Bearer ${ACCESS2}" "${BASE_URL}/SignIn/testlogin")
[[ "$TEST2_CODE" == "200" ]] || fail "testlogin with refreshed access returned $TEST2_CODE"
pass "refreshed access OK"

echo "-- twin refresh within grace using previous refresh token"
TWIN_HTTP=$(curl -sS -w "\n%{http_code}" -X POST "${BASE_URL}/SignIn/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH}\"}")
TWIN_BODY=$(echo "$TWIN_HTTP" | sed '$d')
TWIN_CODE=$(echo "$TWIN_HTTP" | tail -n1)
[[ "$TWIN_CODE" == "200" ]] || fail "grace twin-refresh returned $TWIN_CODE: $TWIN_BODY"
REFRESH3=$(json_field "$TWIN_BODY" refreshToken)
ACCESS3=$(json_field "$TWIN_BODY" accessToken)
pass "grace twin-refresh OK"

echo "-- logout revokes current session"
LOGOUT_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/SignIn/logout" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH3}\"}")
[[ "$LOGOUT_CODE" == "200" ]] || fail "logout returned $LOGOUT_CODE"
pass "logout OK"

echo "-- refresh after logout must fail"
AFTER_LOGOUT_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/SignIn/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH3}\"}")
[[ "$AFTER_LOGOUT_CODE" == "401" ]] || fail "expected 401 after logout, got $AFTER_LOGOUT_CODE"
pass "refresh rejected after logout"

echo "-- mint second pair + revoke-all"
PAIR2_BODY=$(curl -sS "${BASE_URL}/e2e/auth-token-pair")
ACCESS_A=$(json_field "$PAIR2_BODY" accessToken)
REFRESH_A=$(json_field "$PAIR2_BODY" refreshToken)
PAIR3_BODY=$(curl -sS "${BASE_URL}/e2e/auth-token-pair")
REFRESH_B=$(json_field "$PAIR3_BODY" refreshToken)

REVOKE_HTTP=$(curl -sS -w "\n%{http_code}" -X POST "${BASE_URL}/SignIn/revoke-all" \
  -H "Authorization: Bearer ${ACCESS_A}")
REVOKE_BODY=$(echo "$REVOKE_HTTP" | sed '$d')
REVOKE_CODE=$(echo "$REVOKE_HTTP" | tail -n1)
[[ "$REVOKE_CODE" == "200" ]] || fail "revoke-all returned $REVOKE_CODE: $REVOKE_BODY"
pass "revoke-all returned $REVOKE_BODY"

AFTER_A=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/SignIn/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH_A}\"}")
AFTER_B=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/SignIn/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH_B}\"}")
[[ "$AFTER_A" == "401" && "$AFTER_B" == "401" ]] || fail "expected both sessions revoked (got $AFTER_A / $AFTER_B)"
pass "both sessions revoked"

echo "-- unknown refresh rejected"
UNKNOWN_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/SignIn/refresh" \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"definitely-not-a-real-token"}')
[[ "$UNKNOWN_CODE" == "401" ]] || fail "expected 401 for unknown refresh, got $UNKNOWN_CODE"
pass "unknown refresh rejected"

echo
echo "All auth refresh E2E checks passed against ${BASE_URL}"
