///* original
//package com.moontree.mobile
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity: FlutterActivity() {
//}
//*/
//
///* https://github.com/flutter/flutter/issues/94921
//this seemed to fix it, if the issue of the black screen comes up again,
//we can return to this issue number and look for the solution that involves
//.VISIBLE and try that one too.
//*/
//package com.moontree.mobile
//
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
//
//class MainActivity: FlutterActivity() {
//    override fun getBackgroundMode(): BackgroundMode {
//        return if (intent.hasExtra("background_mode")) {
//            BackgroundMode.valueOf(intent.getStringExtra("background_mode")!!)
//        } else {
//            BackgroundMode.transparent
//        }
//    }
//}
//
//
///* https://github.com/flutter/flutter/issues/59552
//import androidx.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivityLaunchConfigs
//import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
//import io.flutter.embedding.android.FlutterFragmentActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugins.GeneratedPluginRegistrant
//
//class MainActivity: FlutterFragmentActivity() {
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
//    }
//    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
//        return BackgroundMode.transparent
//    }
//}
//package smokeAndMirrors
//
//import android.graphics.Bitmap
//import android.graphics.Color
//import android.os.Handler
//import android.view.PixelCopy
//import android.view.View
//import android.widget.FrameLayout
//import android.widget.ImageView
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.android.FlutterSurfaceView
//import io.flutter.embedding.android.TransparencyMode
//
//
//class MainActivity : FlutterActivity() {
//    // hook into pause to create a screenshot of the UI
//    override fun onPause() {
//        val uiScreenshot = this.uiScreenshot ?: return
//        val uiSurfaceView = this.flutterSurfaceView ?: return
//
//        screenshotToken++
//
//        val uiBitmap = Bitmap.createBitmap(uiSurfaceView.width, uiSurfaceView.height, Bitmap.Config.ARGB_8888)
//        uiScreenshot.setImageBitmap(uiBitmap)
//        try {
//            PixelCopy.request(
//                    uiSurfaceView, uiBitmap, {},
//                    Handler()
//            )
//        } catch (e: IllegalArgumentException) {
//        }
//
//        super.onPause()
//    }
//
//    // hook into resume to remove the screenshot (free up resources)
//    override fun onResume() {
//        super.onResume()
//
//        val delay = 500L  // give a bit of time for the Flutter UI to render the first frame
//        val screenshotToken = screenshotToken // don't increment token here!!!
//
//        Handler().postDelayed({
//            // ^ASYNC: still the same token?
//            if (screenshotToken == this.screenshotToken) {
//                uiScreenshot?.setImageDrawable(null)
//            }
//        }, delay)
//    }
//
//    // hook to place the container that contains the uiScreenshot layered below Flutter's UI view
//    override fun setContentView(view: View) {
//        uiScreenshot = ImageView(context)
//        container = FrameLayout(this).also {
//            it.setBackgroundColor(Color.WHITE)
//            it.addView(uiScreenshot)
//            it.addView(view, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
//            super.setContentView(it)
//        }
//    }
//
//    // hook to remember the surface for taking screenshots
//    override fun onFlutterSurfaceViewCreated(flutterSurfaceView: FlutterSurfaceView) {
//        super.onFlutterSurfaceViewCreated(flutterSurfaceView)
//        this.flutterSurfaceView = flutterSurfaceView
//    }
//
//    // make the Flutter UI transparent to see the screenshot behind it
//    override fun getTransparencyMode(): TransparencyMode = TransparencyMode.transparent
//
//    // this container will wrap the uiScreenshot + Flutter's UI view
//    private var container: FrameLayout? = null
//
//    // UI screenshot taken in onPause
//    private var uiScreenshot: ImageView? = null
//
//    // token to guard against async race conditions
//    private var screenshotToken = 0
//
//    // the surface that Flutter uses to draw the UI
//    private var flutterSurfaceView: FlutterSurfaceView? = null
//}
//
//*/




package com.moontree.mobile

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    override fun getBackgroundMode(): BackgroundMode {
        return if (intent.hasExtra("background_mode")) {
            BackgroundMode.valueOf(intent.getStringExtra("background_mode")!!)
        } else {
            BackgroundMode.transparent
        }
    }
//
//	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sendToBackChannel").setMethodCallHandler { call, result ->
//        	if (call.method == "sendToBackground") {
//            	moveTaskToBack(true)
//        	} else {
//	            result.notImplemented()
//    	    }
//    	}
//	}
//
//	override fun onBackPressed() {
//		// send message to flutter that the system back button was pressed
//		val flutterEngine = getFlutterEngine()
//		if (flutterEngine != null) {
//			MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "backButtonChannel").invokeMethod("backButtonPressed", null)
//		}
//	}
}
