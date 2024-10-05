#!/bin/bash
#set -e
start=`date +%s`

flutter test --coverage

python3 versionmanager.py

flutter pub get

sleep 6

# Commit and tag this change.
version=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
git commit -m "release: build and release $version" pubspec.yaml
git tag $version

sleep 6

# This resolves a bug if you'd change the apps name after building the ipa once it does not auto upload afterwards anymore...
rm -rf build/ios/ipa/

flutter build ipa --no-tree-shake-icons --obfuscate --split-debug-info=./obfuscation/$version/ipa/
# open build/ios/archive/Runner.xcarchive/
# create certs here: https://appstoreconnect.apple.com/access/api
sleep 6

xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiIssuer c97ca5fd-1e2f-4be2-8d67-01078f794b3d --apiKey RQXKQ9835X --show-progress

sleep 6

# open ios/Runner.xcworkspace 

flutter build appbundle --no-tree-shake-icons --no-shrink --obfuscate --split-debug-info=./obfuscation/$version/appbundle/

git add obfuscation/*
git commit -m "chore: Checkin symbols for $version" 
git push

end=`date +%s`
runtime=$((end-start))
echo "Took $runtime sec to run"
