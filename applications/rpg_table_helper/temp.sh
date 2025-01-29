python3 versionmanager.py

sleep 20

version=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
git commit -m "release: build and release $version" pubspec.yaml

git commit -m "chore: Checkin symbols for ${version}"
git tag $version

git push
git push origin tag $version
