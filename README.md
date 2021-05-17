# custom_ping

This is a simple way to check your internet connection.

## Why  CustomPing
There are other solutions that try the same goal but with some difficulties on each one. For example `connectivity` checks if the device is connected to a network but don't check if is able to navigate with this network.
Other  package go further checking internet with a ping test, and this is a good solution but is partially incomplete. with limited data plans like the social media bundles you can ping to google but this ping is not a guaranty that you can navigate to google.

Our solutions is call a `get` to the `target url` or by default o google, this get in a optimal conditions take 150ms average.
But as always working with networks is complicated and a positive answer for the `CustomPing` is only telling you that in the moment of the test the device have internet. but always you need to wrap your calls with `try/catch` to handle a proper error from backend

## Getting Started

We recommend to provide the `PingService` via `get_it` or something similar wherever you need to monitor the internet connection
Stream Subscription:

```Dart
PingService().getSubscription(callBack: (e) {
       setState(() {
         pingCount++;
         service =
             'Ping has connection ${e.hasConnection}, with ${e.getNetworkTye} count: $pingCount';
       });
     });
```

Single call:

```Dart
PingService().pingTick();
```



