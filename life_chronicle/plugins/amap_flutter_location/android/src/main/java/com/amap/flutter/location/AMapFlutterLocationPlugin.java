package com.amap.flutter.location;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.amap.api.location.AMapLocationClient;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class AMapFlutterLocationPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "AMapFlutterLocation";
    private static final String METHOD_CHANNEL = "amap_flutter_location";
    private static final String EVENT_CHANNEL = "amap_flutter_location_stream";

    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private Context context;

    private final Map<String, AMapLocationClientImpl> locationClients = new HashMap<>();

    private static String androidKey = "";
    private static String iosKey = "";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANNEL);
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            switch (call.method) {
                case "getPlatformVersion":
                    result.success("Android " + android.os.Build.VERSION.RELEASE);
                    break;

                case "setApiKey":
                    handleSetApiKey(call, result);
                    break;

                case "updatePrivacyStatement":
                    handleUpdatePrivacyStatement(call, result);
                    break;

                case "setLocationOption":
                    handleSetLocationOption(call, result);
                    break;

                case "startLocation":
                    handleStartLocation(call, result);
                    break;

                case "stopLocation":
                    handleStopLocation(call, result);
                    break;

                case "destroy":
                    handleDestroy(call, result);
                    break;

                default:
                    result.notImplemented();
                    break;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error handling method call: " + call.method, e);
            result.error("ERROR", e.getMessage(), null);
        }
    }

    private void handleSetApiKey(@NonNull MethodCall call, @NonNull Result result) {
        String android = call.argument("android");
        String ios = call.argument("ios");

        if (android != null) {
            androidKey = android;
        }
        if (ios != null) {
            iosKey = ios;
        }

        Log.d(TAG, "setApiKey: android=" + androidKey + ", ios=" + iosKey);
        result.success(null);
    }

    private void handleUpdatePrivacyStatement(@NonNull MethodCall call, @NonNull Result result) {
        Boolean hasContains = call.argument("hasContains");
        Boolean hasShow = call.argument("hasShow");
        Boolean hasAgree = call.argument("hasAgree");

        try {
            if (hasContains != null && hasShow != null) {
                AMapLocationClient.updatePrivacyShow(context, hasContains, hasShow);
                Log.d(TAG, "updatePrivacyShow: hasContains=" + hasContains + ", hasShow=" + hasShow);
            }
            if (hasAgree != null) {
                AMapLocationClient.updatePrivacyAgree(context, hasAgree);
                Log.d(TAG, "updatePrivacyAgree: hasAgree=" + hasAgree);
            }
            result.success(null);
        } catch (Exception e) {
            Log.e(TAG, "updatePrivacyStatement error", e);
            result.error("PRIVACY_ERROR", e.getMessage(), null);
        }
    }

    private void handleSetLocationOption(@NonNull MethodCall call, @NonNull Result result) {
        String pluginKey = call.argument("pluginKey");
        if (pluginKey == null) {
            result.error("INVALID_ARGUMENT", "pluginKey is required", null);
            return;
        }

        Map<String, Object> optionMap = new HashMap<>();
        if (call.argument("locationInterval") != null) {
            optionMap.put("locationInterval", call.argument("locationInterval"));
        }
        if (call.argument("needAddress") != null) {
            optionMap.put("needAddress", call.argument("needAddress"));
        }
        if (call.argument("locationMode") != null) {
            optionMap.put("locationMode", call.argument("locationMode"));
        }
        if (call.argument("geoLanguage") != null) {
            optionMap.put("geoLanguage", call.argument("geoLanguage"));
        }
        if (call.argument("onceLocation") != null) {
            optionMap.put("onceLocation", call.argument("onceLocation"));
        }

        AMapLocationClientImpl client = locationClients.get(pluginKey);
        if (client != null) {
            client.setLocationOption(optionMap);
        }

        result.success(null);
    }

    private void handleStartLocation(@NonNull MethodCall call, @NonNull Result result) {
        String pluginKey = call.argument("pluginKey");
        if (pluginKey == null) {
            result.error("INVALID_ARGUMENT", "pluginKey is required", null);
            return;
        }

        Log.d(TAG, "startLocation: pluginKey=" + pluginKey);

        AMapLocationClientImpl client = locationClients.get(pluginKey);
        if (client == null) {
            client = new AMapLocationClientImpl(context, pluginKey, eventSink);
            locationClients.put(pluginKey, client);
        }

        client.startLocation();
        result.success(null);
    }

    private void handleStopLocation(@NonNull MethodCall call, @NonNull Result result) {
        String pluginKey = call.argument("pluginKey");
        if (pluginKey == null) {
            result.error("INVALID_ARGUMENT", "pluginKey is required", null);
            return;
        }

        Log.d(TAG, "stopLocation: pluginKey=" + pluginKey);

        AMapLocationClientImpl client = locationClients.get(pluginKey);
        if (client != null) {
            client.stopLocation();
        }

        result.success(null);
    }

    private void handleDestroy(@NonNull MethodCall call, @NonNull Result result) {
        String pluginKey = call.argument("pluginKey");
        if (pluginKey == null) {
            result.error("INVALID_ARGUMENT", "pluginKey is required", null);
            return;
        }

        Log.d(TAG, "destroy: pluginKey=" + pluginKey);

        AMapLocationClientImpl client = locationClients.remove(pluginKey);
        if (client != null) {
            client.destroy();
        }

        result.success(null);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;

        eventChannel.setStreamHandler(null);
        eventChannel = null;

        for (AMapLocationClientImpl client : locationClients.values()) {
            client.destroy();
        }
        locationClients.clear();

        context = null;
    }
}
