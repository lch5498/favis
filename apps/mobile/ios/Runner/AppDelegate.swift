import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let shareChannel = FlutterMethodChannel(
        name: "housekeeping/share",
        binaryMessenger: controller.binaryMessenger
      )

      shareChannel.setMethodCallHandler { call, result in
        guard call.method == "shareText" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard
          let arguments = call.arguments as? [String: Any],
          let text = arguments["text"] as? String
        else {
          result(
            FlutterError(
              code: "invalid_arguments",
              message: "text is required",
              details: nil
            )
          )
          return
        }

        let activityController = UIActivityViewController(
          activityItems: [text],
          applicationActivities: nil
        )

        if let popover = activityController.popoverPresentationController {
          popover.sourceView = controller.view
          popover.sourceRect = CGRect(
            x: controller.view.bounds.midX,
            y: controller.view.bounds.midY,
            width: 0,
            height: 0
          )
          popover.permittedArrowDirections = []
        }

        controller.present(activityController, animated: true) {
          result(nil)
        }
      }

      let preferencesChannel = FlutterMethodChannel(
        name: "housekeeping/preferences",
        binaryMessenger: controller.binaryMessenger
      )

      preferencesChannel.setMethodCallHandler { call, result in
        guard
          let arguments = call.arguments as? [String: Any],
          let key = arguments["key"] as? String
        else {
          result(
            FlutterError(
              code: "invalid_arguments",
              message: "key is required",
              details: nil
            )
          )
          return
        }

        switch call.method {
        case "getString":
          result(UserDefaults.standard.string(forKey: key))
        case "setString":
          guard let value = arguments["value"] as? String else {
            result(
              FlutterError(
                code: "invalid_arguments",
                message: "value is required",
                details: nil
              )
            )
            return
          }
          UserDefaults.standard.set(value, forKey: key)
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
