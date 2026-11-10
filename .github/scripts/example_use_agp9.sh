#!/usr/bin/env bash
# Switches custom_ping_example to Android Gradle Plugin 9 for a CI leg.
# Usage: example_use_agp9.sh <builtInKotlin: true|false>
#   true  : AGP 9 default, built-in Kotlin compiles the app and the plugin.
#   false : what `flutter create` writes on Flutter 3.47 (android.builtInKotlin=false).
set -euo pipefail
built_in_kotlin="${1:-}"
case "$built_in_kotlin" in
  true|false) ;;
  *) echo "usage: $0 true|false" >&2; exit 2 ;;
esac
android_dir="$(cd "$(dirname "$0")/../../custom_ping_example/android" && pwd)"

sed -i.bak 's/id("com.android.application") version "8.11.1"/id("com.android.application") version "9.1.0"/' \
  "$android_dir/settings.gradle.kts"
sed -i.bak 's/gradle-8.14.3-all.zip/gradle-9.3.1-all.zip/' \
  "$android_dir/gradle/wrapper/gradle-wrapper.properties"
sed -i.bak -E '/^android\.(newDsl|builtInKotlin)=/d' "$android_dir/gradle.properties"
{
  echo "android.newDsl=false"
  echo "android.builtInKotlin=$built_in_kotlin"
} >> "$android_dir/gradle.properties"
if [ "$built_in_kotlin" = "true" ]; then
  sed -i.bak '/id("kotlin-android")/d' "$android_dir/app/build.gradle.kts"
fi
rm -f "$android_dir"/*.bak "$android_dir"/gradle/wrapper/*.bak "$android_dir"/app/*.bak

grep -q 'version "9.1.0"' "$android_dir/settings.gradle.kts"
grep -q 'gradle-9.3.1' "$android_dir/gradle/wrapper/gradle-wrapper.properties"
grep -qx "android.builtInKotlin=$built_in_kotlin" "$android_dir/gradle.properties"
if [ "$built_in_kotlin" = "true" ] && grep -q 'kotlin-android' "$android_dir/app/build.gradle.kts"; then
  echo "kotlin-android is still applied in app/build.gradle.kts" >&2
  exit 1
fi
echo "custom_ping_example now on AGP 9.1.0, Gradle 9.3.1, android.builtInKotlin=$built_in_kotlin"
