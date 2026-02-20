package com.suliuzhe.lifechronicle

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "life_chronicle/device")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getAndroidSdkInt" -> result.success(android.os.Build.VERSION.SDK_INT)
          else -> result.notImplemented()
        }
      }
  }
}
