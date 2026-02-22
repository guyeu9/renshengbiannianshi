-keep class com.amap.api.** { *; }
-keep class com.autonavi.** { *; }
-keep class com.a.a.** { *; }
-keep class com.loc.** { *; }
-keep class com.amap.flutter.** { *; }
-keep class com.amap.flutter.map.AMapFlutterMapPlugin { *; }
-keep class com.amap.flutter.location.** { *; }
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}
-dontwarn com.amap.api.**
-dontwarn com.autonavi.**
-dontwarn com.a.a.**
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
