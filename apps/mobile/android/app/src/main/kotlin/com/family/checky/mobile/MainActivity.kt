package com.family.checky.mobile

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var initialDeepLink: String? = null
    private var latestDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        captureDeepLink(intent, isInitial = true)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "checky/deep_links"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    result.success(initialDeepLink)
                    initialDeepLink = null
                }
                "getLatestLink" -> {
                    result.success(latestDeepLink)
                    latestDeepLink = null
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureDeepLink(intent, isInitial = false)
    }

    private fun captureDeepLink(intent: Intent?, isInitial: Boolean) {
        val uri = intent?.data ?: return
        val scheme = uri.scheme ?: return
        val host = uri.host ?: return

        if ((scheme == "checky" || scheme == "favis") && host == "family-invite") {
            val value = uri.toString()
            latestDeepLink = value
            if (isInitial && initialDeepLink == null) {
                initialDeepLink = value
            }
        }
    }
}
