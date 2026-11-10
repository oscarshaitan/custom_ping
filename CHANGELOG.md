## [0.4.0] - 10 Nov 2026
- **Breaking (build requirements):** needs Flutter 3.35 or later (Dart 3.9), and on Android the Kotlin Gradle plugin 1.8.10 or later, AGP 8 or 9 and JDK 17 (the same floor Flutter 3.35's own Gradle checks enforce). Apps still on Flutter 3.34 or older stay on 0.3.x.
- Builds on Flutter 3.47.9 as well as 3.35.7. No Dart or native behaviour change: the `PingService` API and the Android and iOS code are unchanged.
- Android: the Kotlin Android plugin is applied only where Android Gradle Plugin's built-in Kotlin is off (AGP 8, or AGP 9 with `android.builtInKotlin=false`), so the plugin builds with AGP 8 (Flutter 3.35) and AGP 9 (Flutter 3.47). Kotlin's JVM target is set on the compile tasks instead of `kotlinOptions`, the deprecated `compileSdkVersion`/`minSdkVersion` forms are replaced and the library no longer sets `targetSdkVersion`. The explicit `kotlin-stdlib-jdk7` dependency is dropped; the Kotlin plugin adds the stdlib that matches the app's Kotlin version.
- iOS: the podspec's minimum platform goes from iOS 8.0 to 12.0 (Flutter's own minimum is higher, so no app loses support).
- `flutter_lints` stays in `dev_dependencies` (moved there in 0.3.6).
- Example app: Dart 3 SDK constraint, AGP 8.11.1, Gradle 8.14.3, Kotlin 2.2.20, Java 17, iOS 15.0, so it builds on both Flutter versions.
- CI: a GitHub Actions workflow runs the tests on Flutter 3.35.7 and 3.47.9 and builds the example app (debug APK, iOS simulator) on both, plus AGP 9 legs on 3.47.9.

## [0.3.6] - 10 Nov 2026
- Fix: stop the ping loop when the last subscription is cancelled. Before, the loop kept running, and every cancel followed by a new `getSubscription` started another one, each sending a HEAD to `urlTarget` every `timeout` for the life of the app.
- Move `flutter_lints` from `dependencies` to `dev_dependencies`, so apps that use this package no longer resolve it (it needs Dart 3.8).

## [0.3.5+2] - 02 Oct 2025
- Replace deprecated `jcenter()` with `mavenCentral()` to remove Gradle 9 deprecation warning.

## [0.3.5+1] -  11 March 2025.
#replace .get for .head to reduce the data usage thanks to @danielgomezrico

## [0.3.4+1] -  22 Feb 2025.
#roll back target sdk

## [0.3.3+1] -  18 Feb 2025.
#Update http, gradle and routine updates

## [0.3.2+1] -  18 Feb 2025.
#Update http, gradle and routine updates

## [0.3.1+1] -  18 Feb 2025.
#Update http, gradle and routine updates

## [0.3.0+1] -  18 Feb 2025.
#Update http, gradle and routine updates

## [0.2.3+1] -  17 Jul 2023.
#Remove the support to know the network adapter

## [0.2.2+1] -  17 Jul 2023.
#Remove the support to know the network adapter

## [0.2.1+1] -  17 Jul 2023.
#Fix on ios replace that makes the airplane mode fails

## [0.2.0+1] -  5 Jul 2023.
#Minor versions updates

## [0.1.0+5] -  8 Nov 2022.
#Minor versions updates

## [0.0.1+4] - 17 May 2021.
#NetworkType feature for ios added
#Single call added

## [0.0.1+3] - 17 April 2021.
#NetworkType feature for android added

## [0.0.1+2] - 11 April 2021.
#Migrate to Plugin in order to add channel functions for new features

## [0.0.1+1] - 10 April 2021.
#Improve documentation code

## [0.0.1] - 10 April 2021.
#Initial release
