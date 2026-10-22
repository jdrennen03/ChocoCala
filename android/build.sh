#!/usr/bin/env bash
# Builds dist/ChocoCala.apk without the Android SDK.
#
# Needs: Java 17+, Python 3, npm (only to fetch the ARSCLib/apksig tool jar the first time).
# Signing: set KEYSTORE / KEYSTORE_PASS / KEY_ALIAS, or a new keystore is created at android/chococala.p12.
# Keep that keystore safe: Android only installs updates signed with the same key.
set -euo pipefail
cd "$(dirname "$0")"

VERSION_CODE="${VERSION_CODE:-1}"
VERSION_NAME="${VERSION_NAME:-1.0}"
KEYSTORE="${KEYSTORE:-chococala.p12}"
KEYSTORE_PASS="${KEYSTORE_PASS:-chococala}"
KEY_ALIAS="${KEY_ALIAS:-chococala}"
JAR="tools/lib/apkbuilder-cli.jar"

# ARSCLib (manifest, resources, smali -> dex) and apksig ship together in this npm package.
if [ ! -f "$JAR" ]; then
  mkdir -p tools/lib build/npm
  (cd build/npm && npm pack autojs6-apkbuilder@1.1.0 >/dev/null && tar xzf autojs6-apkbuilder-1.1.0.tgz)
  cp build/npm/package/build/libs/apkbuilder-cli.jar "$JAR"
fi

python3 ../tools/build.py

mkdir -p build/classes
javac -nowarn -cp "$JAR" -d build/classes tools/BuildApk.java tools/SignApk.java
java -cp "$JAR:build/classes" BuildApk . build/ChocoCala-unsigned.apk "$VERSION_CODE" "$VERSION_NAME"

if [ ! -f "$KEYSTORE" ]; then
  echo "Creating a new signing key at android/$KEYSTORE"
  keytool -genkeypair -keystore "$KEYSTORE" -storetype PKCS12 -storepass "$KEYSTORE_PASS" \
    -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=ChocoCala, O=ChocoCala, C=US"
fi

mkdir -p ../dist
java -cp "$JAR:build/classes" SignApk build/ChocoCala-unsigned.apk ../dist/ChocoCala.apk "$KEYSTORE" "$KEYSTORE_PASS" "$KEY_ALIAS"
