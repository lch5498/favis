package com.family.checky.mobile

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val pendingDeepLinkKey = "pendingDeepLink"
    private var initialDeepLink: String? = null
    private var latestDeepLink: String? = null
    private var deepLinkChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        captureDeepLink(intent, isInitial = true)

        deepLinkChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "checky/deep_links"
        )

        deepLinkChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    result.success(consumeDeepLink(initialDeepLink))
                    initialDeepLink = null
                }
                "getLatestLink" -> {
                    result.success(consumeDeepLink(latestDeepLink))
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
            preferences().edit().putString(pendingDeepLinkKey, value).apply()
            if (isInitial && initialDeepLink == null) {
                initialDeepLink = value
            }
            deepLinkChannel?.invokeMethod("onLink", value)
        }
    }

    private fun consumeDeepLink(preferred: String?): String? {
        if (!preferred.isNullOrBlank()) {
            preferences().edit().remove(pendingDeepLinkKey).apply()
            return preferred
        }

        val pending = preferences().getString(pendingDeepLinkKey, null)
        if (pending.isNullOrBlank()) {
            return null
        }

        preferences().edit().remove(pendingDeepLinkKey).apply()
        return pending
    }

    private fun preferences() = getSharedPreferences("checky.deep_links", Context.MODE_PRIVATE)
}
