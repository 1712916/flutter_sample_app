import UIKit
import Flutter
import FBSDKCoreKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    FBSDKCoreKit.ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    if let controller = window?.rootViewController as? FlutterViewController {
      let debugChannel = FlutterMethodChannel(
        name: "meow.channel/debug",
        binaryMessenger: controller.binaryMessenger
      )

      debugChannel.setMethodCallHandler { call, result in
        if call.method == "readFromAppGroup" {
          if let args = call.arguments as? [String: Any],
             let key = args["key"] as? String {
            let sharedDefaults = UserDefaults(suiteName: "group.vinhnt.widgets")
            let value = sharedDefaults?.string(forKey: key)
            print("[iOS Native] 🔍 AppGroup[\(key)] = \(value ?? "nil")")
            result(value ?? "null")
          } else {
            result(FlutterError(code: "INVALID_ARGS", message: "Key missing", details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
