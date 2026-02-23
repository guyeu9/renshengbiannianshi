-keep class com.amap.api.** { *; }
-keep class com.autonavi.** { *; }
-keep class com.a.a.** { *; }
-keep class com.loc.** { *; }
-keep class com.amap.flutter.** { *; }
-keep class com.amap.flutter.map.AMapFlutterMapPlugin { *; }
-keep class com.amap.flutter.location.** { *; }

-keep class com.amap.api.maps.model.** { *; }
-keep class com.amap.api.maps.utils.** { *; }
-keep class com.amap.api.location.** { *; }

-keepclassmembers class com.amap.api.** {
    public <methods>;
}

-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

-dontwarn com.amap.api.**
-dontwarn com.autonavi.**
-dontwarn com.a.a.**

-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.app.** { *; }

-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.app.**

-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
