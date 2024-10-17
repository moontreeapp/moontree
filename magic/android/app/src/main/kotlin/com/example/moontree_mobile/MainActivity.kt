package com.magic.mobile

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.magic.mobile/settings"
    private val USB_DEBUG_CHANNEL = "usb_debug_check"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openSecuritySettings") {
                val intent = Intent(Settings.ACTION_SECURITY_SETTINGS)
                startActivity(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USB_DEBUG_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isUSBDebuggingEnabled") {
                val isEnabled = isUSBDebuggingEnabled()
                result.success(isEnabled)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isUSBDebuggingEnabled(): Boolean {
        return Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ADB_ENABLED,
            0
        ) != 0
    }
}
