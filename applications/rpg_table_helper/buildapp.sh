#!/bin/bash

# Fail fast on errors/undefined vars, and make pipelines fail if any command fails.
set -euo pipefail

# Allow globs like build/ios/ipa/*.ipa to expand to an empty list if nothing matches.
shopt -s nullglob
start=`date +%s`

dart run build_runner build

# flutter test --coverage

python3 versionmanager.py

flutter pub get

sleep 6

# Commit and tag this change.
version=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
git add pubspec.yaml
if ! git diff --cached --quiet; then
  git commit -m "release: build and release $version" pubspec.yaml
else
  echo "No pubspec.yaml changes to commit for version ${version}."
fi

sleep 6

# Workaround: Xcode codesign can fail if Flutter-generated native asset frameworks
# contain macOS extended attributes/resource forks (often introduced by iCloud Drive / FileProvider
# when your project lives under ~/Documents).
#
# Mitigation: put Flutter build outputs (build/...) onto a non-FileProvider filesystem by
# symlinking ./build -> a directory in $TMPDIR.
BUILD_ROOT="${TMPDIR:-/tmp}/rpg_table_helper_build"
rm -rf "${BUILD_ROOT}" || true
mkdir -p "${BUILD_ROOT}"

# Recreate ./build as a symlink to the temp build directory.
rm -rf build || true
ln -s "${BUILD_ROOT}" build

# Ensure a clean native_assets directory before archiving.
rm -rf build/native_assets || true

# This resolves a bug if you'd change the apps name after building the ipa once it does not auto upload afterwards anymore...
rm -rf build/ios/ipa/

flutter build ipa --no-tree-shake-icons --obfuscate --split-debug-info=./obfuscation/$version/ipa/
# open build/ios/archive/Runner.xcarchive/
# create certs here: https://appstoreconnect.apple.com/access/api
sleep 6

API_ISSUER_ID="c97ca5fd-1e2f-4be2-8d67-01078f794b3d"
API_KEY_ID="RQXKQ9835X"

# Resolve the IPA path (fail if none or multiple are found)
ipas=(build/ios/ipa/*.ipa)
if (( ${#ipas[@]} == 0 )); then
  echo "ERROR: No IPA found at build/ios/ipa/*.ipa" >&2
  exit 1
fi
if (( ${#ipas[@]} > 1 )); then
  echo "ERROR: Multiple IPAs found; please upload one explicitly:" >&2
  printf ' - %s\n' "${ipas[@]}" >&2
  exit 1
fi
IPA_FILE="${ipas[0]}"

# altool needs the App Store Connect private key (.p8). By default it searches for
# AuthKey_<API_KEY_ID>.p8 in a few standard directories, but we also support an explicit path.
P8_FILE_PATH="${ASC_P8_FILE_PATH:-}"
if [[ -z "${P8_FILE_PATH}" ]]; then
  # Common locations (based on altool help output)
  candidates=(
    "${PWD}/private_keys/AuthKey_${API_KEY_ID}.p8"
    "${HOME}/private_keys/AuthKey_${API_KEY_ID}.p8"
    "${HOME}/.private_keys/AuthKey_${API_KEY_ID}.p8"
    "${HOME}/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8"
  )
  if [[ -n "${API_PRIVATE_KEYS_DIR:-}" ]]; then
    candidates+=("${API_PRIVATE_KEYS_DIR}/AuthKey_${API_KEY_ID}.p8")
  fi
  for c in "${candidates[@]}"; do
    if [[ -f "${c}" ]]; then
      P8_FILE_PATH="${c}"
      break
    fi
  done
fi

if [[ -z "${P8_FILE_PATH}" ]]; then
  cat >&2 <<EOM
ERROR: Missing App Store Connect API private key file.

altool could not find: AuthKey_${API_KEY_ID}.p8

Fix options:
  1) Place the key at: ./private_keys/AuthKey_${API_KEY_ID}.p8
     (create the folder if needed)
  2) Or export an explicit path before running:
       export ASC_P8_FILE_PATH="/path/to/AuthKey_${API_KEY_ID}.p8"
  3) Or set API_PRIVATE_KEYS_DIR to a directory containing that file name.
EOM
  exit 1
fi

echo "Uploading IPA: ${IPA_FILE}"
echo "Using ASC key file: ${P8_FILE_PATH}"

# NOTE: Do not quote globs like build/ios/ipa/*.ipa; quoting prevents shell expansion.
xcrun altool --upload-app -f "${IPA_FILE}" \
  --api-key "${API_KEY_ID}" \
  --api-issuer "${API_ISSUER_ID}" \
  --p8-file-path "${P8_FILE_PATH}" \
  --show-progress

sleep 6

# open ios/Runner.xcworkspace

flutter build appbundle --no-tree-shake-icons --no-shrink --obfuscate --split-debug-info=./obfuscation/$version/appbundle/

git add -f obfuscation/*
git commit -m "chore: Checkin symbols for ${version}"
git tag $version

git push
git push origin "refs/tags/${version}"


end=`date +%s`
runtime=$((end-start))
echo "Took $runtime sec to run"
