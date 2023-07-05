import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart';

class PingService {
  static const MethodChannel _channel = const MethodChannel('custom_ping');

  ///This Stream is the one in charge of continuously doing the ping to the designated url.
  late Stream<CustomPingInfo>? _connection;

  ///The [urlTarget] is the destination to ping as default we are going to use google.com but could be a designated url on your backend or functions in your firebase
  final String urlTarget;

  ///The [timeout] by default is 3 seconds but could be adjusted to your ouw preference timeout when this is completed will throw the [ReachServerFailException]
  final Duration timeout;

  ///Base http Client to realize the connection to the [urlTarget]
  final Client _httpClient = Client();

  ///This counter hold the amount off subscriptions that we have
  int _clients = 0;

  PingService({
    this.urlTarget = 'https://www.google.com/',
    this.timeout = const Duration(seconds: 3),
  }) {
    _restartStream();
  }

  ///Main infinite loop this loop continuously will try to complete a fetch on the [urlTarget]
  Stream<CustomPingInfo> _pingTick() async* {
    while (true) {
      await Future.delayed(timeout);
      yield (await pingTick());
    }
  }

  Future<CustomPingInfo> pingTick() async {
    var networkType = await _channel.invokeMethod("getNetworkType");
    bool hasConnection = await _pingServer();
    return CustomPingInfo(networkType, hasConnection);
  }

  ///set the Stream to null in order to avoid unnecessary calls
  void _pauseStream() {
    _connection = null;
  }

  ///set the Stream to start looping the get calls
  void _restartStream() {
    _connection = _pingTick().asBroadcastStream(
      onCancel: (_) {
        ///when don't have any one listen to the ping service we stop the calls
        _clients--;
        if (_clients == 0) {
          _pauseStream();
        }
      },
      onListen: (_) {
        _clients++;
      },
    );
  }

  ///Calls get to the [urlTarget] the timing between pings and the timeout are the same
  Future<bool> _pingServer() async {
    try {
      Uri url = Uri.parse(urlTarget);

      Response response = await _httpClient.get(url).timeout(timeout, onTimeout: () {
        throw ReachServerFailException();
      });

      return response.statusCode == 200;
    } on Exception catch (_) {
      return false;
    }
  }

  ///Return a Subscription to the Ping Stream
  StreamSubscription getSubscription({required Function(CustomPingInfo) callBack}) {
    if (_connection == null) {
      _restartStream();
    }

    return _connection!.listen(callBack);
  }
}

class ReachServerFailException implements Exception {}

///Enum that define the possible networks
enum NetWorkType { WIFI, CELLULAR, NONE }

///
class CustomPingInfo {
  final String _netWorkType;
  final bool hasConnection;

  CustomPingInfo(this._netWorkType, this.hasConnection);

  NetWorkType get getNetworkTye =>
      NetWorkType.values.firstWhere((element) => element.toString().contains(_netWorkType.toUpperCase()));
}
