package com.amap.flutter.map

import androidx.lifecycle.Lifecycle
import com.amap.flutter.map.utils.LogUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter

class AMapFlutterMapPlugin : FlutterPlugin, ActivityAware {
    companion object {
        private const val CLASS_NAME = "AMapFlutterMapPlugin"
        private const val VIEW_TYPE = "com.amap.flutter.map"
    }

    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var lifecycle: Lifecycle? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        LogUtil.i(CLASS_NAME, "onAttachedToEngine==>")
        pluginBinding = binding
        binding
            .platformViewRegistry
            .registerViewFactory(
                VIEW_TYPE,
                AMapPlatformViewFactory(
                    binding.binaryMessenger,
                    object : LifecycleProvider {
                        override fun getLifecycle(): Lifecycle? {
                            return lifecycle
                        }
                    }
                )
            )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        LogUtil.i(CLASS_NAME, "onDetachedFromEngine==>")
        pluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        LogUtil.i(CLASS_NAME, "onAttachedToActivity==>")
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    }

    override fun onDetachedFromActivity() {
        LogUtil.i(CLASS_NAME, "onDetachedFromActivity==>")
        lifecycle = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        LogUtil.i(CLASS_NAME, "onReattachedToActivityForConfigChanges==>")
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        LogUtil.i(CLASS_NAME, "onDetachedFromActivityForConfigChanges==>")
        onDetachedFromActivity()
    }
}
