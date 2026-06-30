import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  let pendingDeepLinkKey = "checky.pendingDeepLink"
  var initialDeepLink: String?
  var latestDeepLink: String?
  var deepLinkChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let url = launchOptions?[.url] as? URL {
      handleDeepLink(url, isInitial: true)
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

        let subject = arguments["subject"] as? String ?? "체키 가족 초대"
        let presenter = self.topViewController(from: controller)

        let activityController = UIActivityViewController(
          activityItems: [text],
          applicationActivities: nil
        )
        activityController.setValue(subject, forKey: "subject")

        if let popover = activityController.popoverPresentationController {
          popover.sourceView = presenter.view
          popover.sourceRect = CGRect(
            x: presenter.view.bounds.midX,
            y: presenter.view.bounds.midY,
            width: 0,
            height: 0
          )
          popover.permittedArrowDirections = []
        }

        presenter.present(activityController, animated: true) {
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

      deepLinkChannel = FlutterMethodChannel(
        name: "checky/deep_links",
        binaryMessenger: controller.binaryMessenger
      )

      deepLinkChannel?.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "getInitialLink":
          result(self?.consumeDeepLink(preferred: self?.initialDeepLink))
          self?.initialDeepLink = nil
        case "getLatestLink":
          result(self?.consumeDeepLink(preferred: self?.latestDeepLink))
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
    if handleDeepLink(url, isInitial: false) {
      return true
    }

    return super.application(app, open: url, options: options)
  }

  @discardableResult
  func handleDeepLink(_ url: URL, isInitial: Bool) -> Bool {
    guard
      let scheme = url.scheme,
      let host = url.host,
      (scheme == "checky" || scheme == "favis"),
      host == "family-invite"
    else {
      return false
    }

    let value = url.absoluteString
    latestDeepLink = value
    UserDefaults.standard.set(value, forKey: pendingDeepLinkKey)
    if isInitial && initialDeepLink == nil {
      initialDeepLink = value
    }

    DispatchQueue.main.async { [weak self] in
      self?.deepLinkChannel?.invokeMethod("onLink", arguments: value)
    }

    return true
  }

  func consumeDeepLink(preferred: String?) -> String? {
    if let preferred, !preferred.isEmpty {
      UserDefaults.standard.removeObject(forKey: pendingDeepLinkKey)
      return preferred
    }

    guard let pending = UserDefaults.standard.string(forKey: pendingDeepLinkKey), !pending.isEmpty else {
      return nil
    }

    UserDefaults.standard.removeObject(forKey: pendingDeepLinkKey)
    return pending
  }

  func topViewController(from controller: UIViewController) -> UIViewController {
    if let presented = controller.presentedViewController {
      return topViewController(from: presented)
    }

    if let navigation = controller as? UINavigationController,
       let visible = navigation.visibleViewController {
      return topViewController(from: visible)
    }

    if let tab = controller as? UITabBarController,
       let selected = tab.selectedViewController {
      return topViewController(from: selected)
    }

    return controller
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
