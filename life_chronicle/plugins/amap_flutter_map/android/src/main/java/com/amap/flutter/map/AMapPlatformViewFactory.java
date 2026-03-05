package com.amap.flutter.map;

import android.content.Context;

import com.amap.api.maps.model.CameraPosition;
import com.amap.flutter.map.utils.ConvertUtil;
import com.amap.flutter.map.utils.LogUtil;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * @author whm
 * @date 2020/10/27 4:08 PM
 * @mail hongming.whm@alibaba-inc.com
 * @since
 */
class AMapPlatformViewFactory extends PlatformViewFactory {
    private static final String CLASS_NAME = "AMapPlatformViewFactory";
    private final BinaryMessenger binaryMessenger;
    private final LifecycleProvider lifecycleProvider;
    AMapPlatformViewFactory(BinaryMessenger binaryMessenger,
                            LifecycleProvider lifecycleProvider) {
        super(StandardMessageCodec.INSTANCE);
        this.binaryMessenger = binaryMessenger;
        this.lifecycleProvider = lifecycleProvider;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        LogUtil.i(CLASS_NAME, "=== create START ===");
        LogUtil.i(CLASS_NAME, "viewId: " + viewId);
        LogUtil.i(CLASS_NAME, "args: " + args);
        final AMapOptionsBuilder builder = new AMapOptionsBuilder();
        Map<String, Object> params = null;
        try {
            ConvertUtil.density = context.getResources().getDisplayMetrics().density;
            params = (Map<String, Object>) args;
            LogUtil.i(CLASS_NAME,"params==>" + params);
            
            if (params.containsKey("privacyStatement")) {
                LogUtil.i(CLASS_NAME, "Processing privacyStatement...");
                ConvertUtil.setPrivacyStatement(context, params.get("privacyStatement"));
            } else {
                LogUtil.w(CLASS_NAME, "privacyStatement NOT found in params!");
            }

            Object options = ((Map<String, Object>) args).get("options");
            LogUtil.i(CLASS_NAME, "options: " + options);
            if(null != options) {
                ConvertUtil.interpretAMapOptions(options, builder);
            }

            if (params.containsKey("initialCameraPosition")) {
                LogUtil.i(CLASS_NAME, "Processing initialCameraPosition...");
                CameraPosition cameraPosition = ConvertUtil.toCameraPosition(params.get("initialCameraPosition"));
                builder.setCamera(cameraPosition);
            }

            if (params.containsKey("markersToAdd")) {
                LogUtil.i(CLASS_NAME, "Processing markersToAdd...");
                builder.setInitialMarkers(params.get("markersToAdd"));
            }
            if (params.containsKey("polylinesToAdd")) {
                LogUtil.i(CLASS_NAME, "Processing polylinesToAdd...");
                builder.setInitialPolylines(params.get("polylinesToAdd"));
            }

            if (params.containsKey("polygonsToAdd")) {
                LogUtil.i(CLASS_NAME, "Processing polygonsToAdd...");
                builder.setInitialPolygons(params.get("polygonsToAdd"));
            }


            if (params.containsKey("apiKey")) {
                LogUtil.i(CLASS_NAME, "Processing apiKey...");
                ConvertUtil.checkApiKey(params.get("apiKey"));
            } else {
                LogUtil.w(CLASS_NAME, "apiKey NOT found in params!");
            }

            if (params.containsKey("debugMode")) {
                LogUtil.isDebugMode = ConvertUtil.toBoolean(params.get("debugMode"));
                LogUtil.i(CLASS_NAME, "debugMode: " + LogUtil.isDebugMode);
            }

        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "create ERROR", e);
            LogUtil.e(CLASS_NAME, "Error type: " + e.getClass().getName());
            LogUtil.e(CLASS_NAME, "Error message: " + e.getMessage());
        }
        LogUtil.i(CLASS_NAME, "Building AMapPlatformView...");
        PlatformView view = builder.build(viewId, context, binaryMessenger, lifecycleProvider);
        LogUtil.i(CLASS_NAME, "=== create END, view: " + view + " ===");
        return view;
    }
}
