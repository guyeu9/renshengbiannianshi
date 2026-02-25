package com.amap.flutter.location;

import android.content.Context;
import android.util.Log;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;

import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class AMapLocationClientImpl implements AMapLocationListener {

    private static final String TAG = "AMapLocationClientImpl";

    private Context mContext;
    private AMapLocationClientOption locationOption = new AMapLocationClientOption();
    private AMapLocationClient locationClient = null;
    private EventChannel.EventSink mEventSink;

    private String mPluginKey;

    public AMapLocationClientImpl(Context context, String pluginKey, EventChannel.EventSink eventSink) {
        mContext = context;
        mPluginKey = pluginKey;
        mEventSink = eventSink;
        Log.d(TAG, "Created client for pluginKey=" + pluginKey);
    }

    public void startLocation() {
        Log.d(TAG, "startLocation called, pluginKey=" + mPluginKey);

        try {
            if (locationClient == null) {
                locationClient = new AMapLocationClient(mContext);
                Log.d(TAG, "Created new AMapLocationClient");
            }

            if (locationOption != null) {
                locationClient.setLocationOption(locationOption);
            }
            locationClient.setLocationListener(this);
            locationClient.startLocation();
            Log.d(TAG, "Location started successfully");

        } catch (Exception e) {
            Log.e(TAG, "Failed to start location", e);
            if (mEventSink != null) {
                Map<String, Object> errorResult = new java.util.HashMap<>();
                errorResult.put("errorCode", -1);
                errorResult.put("errorInfo", "Failed to start location: " + e.getMessage());
                errorResult.put("pluginKey", mPluginKey);
                mEventSink.success(errorResult);
            }
        }
    }

    public void stopLocation() {
        Log.d(TAG, "stopLocation called, pluginKey=" + mPluginKey);

        if (locationClient != null) {
            locationClient.stopLocation();
            Log.d(TAG, "Location stopped");
        }
    }

    public void destroy() {
        Log.d(TAG, "destroy called, pluginKey=" + mPluginKey);

        if (locationClient != null) {
            locationClient.stopLocation();
            locationClient.onDestroy();
            locationClient = null;
            Log.d(TAG, "Location client destroyed");
        }
    }

    @Override
    public void onLocationChanged(AMapLocation location) {
        Log.d(TAG, "onLocationChanged: " + (location != null ? "errorCode=" + location.getErrorCode() : "null"));

        if (mEventSink == null) {
            Log.w(TAG, "EventSink is null, cannot send location result");
            return;
        }

        Map<String, Object> result = Utils.buildLocationResultMap(location);
        result.put("pluginKey", mPluginKey);
        mEventSink.success(result);
    }

    public void setLocationOption(Map optionMap) {
        Log.d(TAG, "setLocationOption: " + optionMap);

        if (locationOption == null) {
            locationOption = new AMapLocationClientOption();
        }

        if (optionMap.containsKey("locationInterval")) {
            Object value = optionMap.get("locationInterval");
            if (value instanceof Integer) {
                locationOption.setInterval(((Integer) value).longValue());
            } else if (value instanceof Long) {
                locationOption.setInterval((Long) value);
            }
        }

        if (optionMap.containsKey("needAddress")) {
            locationOption.setNeedAddress((boolean) optionMap.get("needAddress"));
        }

        if (optionMap.containsKey("locationMode")) {
            try {
                locationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.values()[(int) optionMap.get("locationMode")]);
            } catch (Throwable e) {
                Log.e(TAG, "Failed to set locationMode", e);
            }
        }

        if (optionMap.containsKey("geoLanguage")) {
            try {
                locationOption.setGeoLanguage(AMapLocationClientOption.GeoLanguage.values()[(int) optionMap.get("geoLanguage")]);
            } catch (Throwable e) {
                Log.e(TAG, "Failed to set geoLanguage", e);
            }
        }

        if (optionMap.containsKey("onceLocation")) {
            locationOption.setOnceLocation((boolean) optionMap.get("onceLocation"));
        }

        if (locationClient != null) {
            locationClient.setLocationOption(locationOption);
        }
    }
}
