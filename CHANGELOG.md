## [0.3.6] - 5 Nov 2026
- Fix: stop the ping loop when the last subscription is cancelled. Before, the loop kept running, and every cancel followed by a new `getSubscription` started another one, each sending a HEAD to `urlTarget` every `timeout` for the life of the app.

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
