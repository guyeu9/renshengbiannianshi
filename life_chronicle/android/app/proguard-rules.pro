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

-keep class * extends com.amap.api.maps.** { *; }
-keep class * implements com.amap.api.maps.** { *; }

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

# Gson - 保留泛型签名（flutter_local_notifications 依赖）
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# flutter_local_notifications - 保留通知相关类
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class r1.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Workmanager - 保留后台任务入口点
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.CoroutineWorker
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker
-keepclassmembers class * extends androidx.work.Worker {
    public androidx.work.Result doWork();
}
-keepclassmembers class * extends androidx.work.CoroutineWorker {
    public java.lang.Object doWork(kotlinx.coroutines.CoroutineScope);
}

# Flutter Secure Storage - 保留安全存储相关类
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.it_nomads.flutter_secure_storage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**
-dontwarn com.it_nomads.flutter_secure_storage.**

# Android Security - 保留加密相关类
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }
-keep class android.security.** { *; }
-keep class androidx.security.** { *; }

# SharedPreferences - 保留序列化相关
-keep class android.content.SharedPreferences$Editor { *; }
-keep class android.content.SharedPreferences { *; }

# 保留所有 Dart/Flutter 插件注册类
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# 保留所有 JSON 序列化模型类的字段
-keepclassmembers class * {
    @com.google.gson.annotations.* <fields>;
}

# 保留所有 Parcelable 序列化类
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# 保留 Serializable 类的 serialVersionUid
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
