import Flutter
import UIKit

public class SwiftCustomPingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "custom_ping", binaryMessenger: registrar.messenger())
    let instance = SwiftCustomPingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getNetworkType" else {
        result(FlutterMethodNotImplemented)
        return
      }
    guard let reachability = Reachability() else {
        result("none")
        return
    }
    reachability.whenReachable = { reachability in
        DispatchQueue.main.async {
            if reachability.connection == .wifi {
                result("wifi")
            } else if reachability.connection == .cellular {
                result("cellular")
            } else {
                result("none")
            }
        }
    }
    do {
        try reachability.startNotifier()
    } catch {
        result("none")
    }
  }
}
