package com.amap.flutter.map;

import android.content.Context;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.amap.api.maps.AMap;
import com.amap.api.maps.AMapOptions;
import com.amap.api.maps.TextureMapView;
import com.amap.flutter.map.core.MapController;
import com.amap.flutter.map.overlays.marker.MarkersController;
import com.amap.flutter.map.overlays.polygon.PolygonsController;
import com.amap.flutter.map.overlays.polyline.PolylinesController;
import com.amap.flutter.map.utils.LogUtil;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;


/**
 * @author whm
 * @date 2020/10/27 5:49 PM
 * @mail hongming.whm@alibaba-inc.com
 * @since
 */
public class AMapPlatformView
        implements
        DefaultLifecycleObserver,
        ActivityPluginBinding.OnSaveInstanceStateListener,
        MethodChannel.MethodCallHandler,
        PlatformView {
    private static final String CLASS_NAME = "AMapPlatformView";
    private final MethodChannel methodChannel;

    private MapController mapController;
    private MarkersController markersController;
    private PolylinesController polylinesController;
    private PolygonsController polygonsController;

    private TextureMapView mapView;

    private boolean disposed = false;

    private final Map<String, MyMethodCallHandler> myMethodCallHandlerMap;

    AMapPlatformView(int id,
                     Context context,
                     BinaryMessenger binaryMessenger,
                     LifecycleProvider lifecycleProvider,
                     AMapOptions options) {

        LogUtil.i(CLASS_NAME, "=== AMapPlatformView constructor START ===");
        LogUtil.i(CLASS_NAME, "id: " + id);
        LogUtil.i(CLASS_NAME, "context: " + context);
        LogUtil.i(CLASS_NAME, "options: " + options);

        methodChannel = new MethodChannel(binaryMessenger, "amap_flutter_map_" + id);
        methodChannel.setMethodCallHandler(this);
        myMethodCallHandlerMap = new HashMap<String, MyMethodCallHandler>(8);

        try {
            LogUtil.i(CLASS_NAME, "Creating TextureMapView...");
            mapView = new TextureMapView(context, options);
            LogUtil.i(CLASS_NAME, "TextureMapView created successfully");
            
            LogUtil.i(CLASS_NAME, "Getting AMap instance...");
            AMap amap = mapView.getMap();
            LogUtil.i(CLASS_NAME, "AMap instance obtained: " + (amap != null ? "success" : "null"));
            
            LogUtil.i(CLASS_NAME, "Creating MapController...");
            mapController = new MapController(methodChannel, mapView);
            LogUtil.i(CLASS_NAME, "MapController created");
            
            LogUtil.i(CLASS_NAME, "Creating MarkersController...");
            markersController = new MarkersController(methodChannel, amap);
            LogUtil.i(CLASS_NAME, "MarkersController created");
            
            LogUtil.i(CLASS_NAME, "Creating PolylinesController...");
            polylinesController = new PolylinesController(methodChannel, amap);
            LogUtil.i(CLASS_NAME, "PolylinesController created");
            
            LogUtil.i(CLASS_NAME, "Creating PolygonsController...");
            polygonsController = new PolygonsController(methodChannel, amap);
            LogUtil.i(CLASS_NAME, "PolygonsController created");
            
            initMyMethodCallHandlerMap();
            lifecycleProvider.getLifecycle().addObserver(this);
            LogUtil.i(CLASS_NAME, "=== AMapPlatformView constructor END ===");
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "=== AMapPlatformView constructor ERROR ===", e);
            LogUtil.e(CLASS_NAME, "Error type: " + e.getClass().getName());
            LogUtil.e(CLASS_NAME, "Error message: " + e.getMessage());
        }
    }

    private void initMyMethodCallHandlerMap() {
        String[] methodIdArray = mapController.getRegisterMethodIdArray();
        if (null != methodIdArray && methodIdArray.length > 0) {
            for (String methodId : methodIdArray) {
                myMethodCallHandlerMap.put(methodId, mapController);
            }
        }

        methodIdArray = markersController.getRegisterMethodIdArray();
        if (null != methodIdArray && methodIdArray.length > 0) {
            for (String methodId : methodIdArray) {
                myMethodCallHandlerMap.put(methodId, markersController);
            }
        }

        methodIdArray = polylinesController.getRegisterMethodIdArray();
        if (null != methodIdArray && methodIdArray.length > 0) {
            for (String methodId : methodIdArray) {
                myMethodCallHandlerMap.put(methodId, polylinesController);
            }
        }

        methodIdArray = polygonsController.getRegisterMethodIdArray();
        if (null != methodIdArray && methodIdArray.length > 0) {
            for (String methodId : methodIdArray) {
                myMethodCallHandlerMap.put(methodId, polygonsController);
            }
        }
    }


    public MapController getMapController() {
        return mapController;
    }

    public MarkersController getMarkersController() {
        return markersController;
    }

    public PolylinesController getPolylinesController() {
        return polylinesController;
    }

    public PolygonsController getPolygonsController() {
        return polygonsController;
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        LogUtil.i(CLASS_NAME, "onMethodCall==>" + call.method + ", arguments==> " + call.arguments);
        String methodId = call.method;
        if (myMethodCallHandlerMap.containsKey(methodId)) {
            myMethodCallHandlerMap.get(methodId).doMethodCall(call, result);
        } else {
            LogUtil.w(CLASS_NAME, "onMethodCall, the methodId: " + call.method + ", not implemented");
            result.notImplemented();
        }
    }


    @Override
    public void onCreate(@NonNull LifecycleOwner owner) {
        LogUtil.i(CLASS_NAME, "=== onCreate START ===");
        LogUtil.i(CLASS_NAME, "disposed: " + disposed);
        LogUtil.i(CLASS_NAME, "mapView: " + (mapView != null ? "not null" : "null"));
        try {
            if (disposed) {
                LogUtil.w(CLASS_NAME, "onCreate: disposed is true, returning");
                return;
            }
            if (null != mapView) {
                LogUtil.i(CLASS_NAME, "Calling mapView.onCreate(null)...");
                mapView.onCreate(null);
                LogUtil.i(CLASS_NAME, "mapView.onCreate(null) completed");
            } else {
                LogUtil.e(CLASS_NAME, "onCreate: mapView is null!");
            }
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "onCreate ERROR", e);
            LogUtil.e(CLASS_NAME, "Error type: " + e.getClass().getName());
            LogUtil.e(CLASS_NAME, "Error message: " + e.getMessage());
        }
        LogUtil.i(CLASS_NAME, "=== onCreate END ===");
    }

    @Override
    public void onStart(@NonNull LifecycleOwner owner) {
        LogUtil.i(CLASS_NAME, "onStart==>");
    }

    @Override
    public void onResume(@NonNull LifecycleOwner owner) {
        LogUtil.i(CLASS_NAME, "onResume==>");
        try {
            if (disposed) {
                return;
            }
            if (null != mapView) {
                mapView.onResume();
            }
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "onResume", e);
        }
    }

    @Override
    public void onPause(@NonNull LifecycleOwner owner) {
        LogUtil.i(CLASS_NAME, "onPause==>");
        try {
            if (disposed) {
                return;
            }
            mapView.onPause();
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "onPause", e);
        }
    }

    @Override
    public void onStop(@NonNull LifecycleOwner owner) {
        LogUtil.i(CLASS_NAME, "onStop==>");
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner owner) {
        LogUtil.i(CLASS_NAME, "onDestroy==>");
        try {
            if (disposed) {
                return;
            }
            destroyMapViewIfNecessary();
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "onDestroy", e);
        }
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle bundle) {
        LogUtil.i(CLASS_NAME, "onDestroy==>");
        try {
            if (disposed) {
                return;
            }
            mapView.onSaveInstanceState(bundle);
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "onSaveInstanceState", e);
        }
    }

    @Override
    public void onRestoreInstanceState(@Nullable Bundle bundle) {
        LogUtil.i(CLASS_NAME, "onDestroy==>");
        try {
            if (disposed) {
                return;
            }
            mapView.onCreate(bundle);
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "onRestoreInstanceState", e);
        }
    }


    @Override
    public View getView() {
        LogUtil.i(CLASS_NAME, "getView==>");
        return mapView;
    }

    @Override
    public void dispose() {
        LogUtil.i(CLASS_NAME, "dispose==>");
        try {
            if (disposed) {
                return;
            }
            methodChannel.setMethodCallHandler(null);
            destroyMapViewIfNecessary();
            disposed = true;
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "dispose", e);
        }
    }

    private void destroyMapViewIfNecessary() {
        if (mapView == null) {
            return;
        }
        mapView.onDestroy();
    }


}
