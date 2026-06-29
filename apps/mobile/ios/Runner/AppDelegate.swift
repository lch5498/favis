import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var initialDeepLink: String?
  private var latestDeepLink: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let url = launchOptions?[.url] as? URL {
      captureDeepLink(url, isInitial: true)
    }

    if let controller = window?.rootViewController as? FlutterViewController {
      let shareChannel = FlutterMethodChannel(
        name: "checky/share",
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
        name: "checky/preferences",
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

      let deepLinkChannel = FlutterMethodChannel(
        name: "checky/deep_links",
        binaryMessenger: controller.binaryMessenger
      )

      deepLinkChannel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "getInitialLink":
          result(self?.initialDeepLink)
          self?.initialDeepLink = nil
        case "getLatestLink":
          result(self?.latestDeepLink)
          self?.latestDeepLink = nil
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    captureDeepLink(url, isInitial: false)
    return super.application(app, open: url, options: options)
  }

  private func captureDeepLink(_ url: URL, isInitial: Bool) {
    guard
      let scheme = url.scheme,
      let host = url.host,
      (scheme == "checky" || scheme == "favis"),
      host == "family-invite"
    else {
      return
    }

    let value = url.absoluteString
    latestDeepLink = value
    if isInitial && initialDeepLink == nil {
      initialDeepLink = value
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
