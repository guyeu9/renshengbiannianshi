package com.suliuzhe.lifechronicle

import android.os.Bundle
import com.amap.api.location.AMapLocationClient
import com.amap.api.maps.MapsInitializer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    initAMapPrivacy()
    super.onCreate(savedInstanceState)
  }

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

  private fun initAMapPrivacy() {
    MapsInitializer.updatePrivacyShow(this, true, true)
    MapsInitializer.updatePrivacyAgree(this, true)
    AMapLocationClient.updatePrivacyShow(this, true, true)
    AMapLocationClient.updatePrivacyAgree(this, true)
  }
}
