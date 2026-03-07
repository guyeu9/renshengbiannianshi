Run flutter build apk --release
Upgrading build.gradle
Your project is configured with Android NDK 28.0.12674087, but the following plugin(s) depend on a different Android NDK version:
Running Gradle task 'assembleRelease'...                        
- amap_flutter_location requires Android NDK 27.0.12077973
- connectivity_plus requires Android NDK 27.0.12077973
- device_info_plus requires Android NDK 27.0.12077973
- file_picker requires Android NDK 27.0.12077973
- flutter_local_notifications requires Android NDK 27.0.12077973
- flutter_plugin_android_lifecycle requires Android NDK 27.0.12077973
- flutter_secure_storage requires Android NDK 27.0.12077973
- image_picker_android requires Android NDK 27.0.12077973
- integration_test requires Android NDK 28.2.13676358
- path_provider_android requires Android NDK 27.0.12077973
- permission_handler_android requires Android NDK 27.0.12077973
- share_plus requires Android NDK 27.0.12077973
- sqflite_android requires Android NDK 27.0.12077973
- sqlite3_flutter_libs requires Android NDK 27.0.12077973
- url_launcher_android requires Android NDK 27.0.12077973
- vibration requires Android NDK 27.0.12077973
- webview_flutter_android requires Android NDK 27.0.12077973
- workmanager_android requires Android NDK 27.0.12077973
Fix this issue by using the highest Android NDK version (they are backward compatible).
Add the following to /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/android/app/build.gradle:

    android {
        ndkVersion = "28.2.13676358"
        ...
    }
Checking the license for package Android SDK Platform 33 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Platform 33 accepted.
Preparing "Install Android SDK Platform 33 (revision 3)".
"Install Android SDK Platform 33 (revision 3)" ready.
Installing Android SDK Platform 33 in /usr/local/lib/android/sdk/platforms/android-33
"Install Android SDK Platform 33 (revision 3)" complete.
"Install Android SDK Platform 33 (revision 3)" finished.
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:6: error: package com.amap.api.location does not exist
import com.amap.api.location.AMapLocation;
                            ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:7: error: package com.amap.api.location does not exist
import com.amap.api.location.AMapLocationClient;
                            ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:8: error: package com.amap.api.location does not exist
import com.amap.api.location.AMapLocationClientOption;
                            ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:9: error: package com.amap.api.location does not exist
import com.amap.api.location.AMapLocationListener;
                            ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:15: error: cannot find symbol
public class AMapLocationClientImpl implements AMapLocationListener {
                                               ^
  symbol: class AMapLocationListener
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:20: error: cannot find symbol
    private AMapLocationClientOption locationOption = new AMapLocationClientOption();
            ^
  symbol:   class AMapLocationClientOption
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:21: error: cannot find symbol
    private AMapLocationClient locationClient = null;
            ^
  symbol:   class AMapLocationClient
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:90: error: cannot find symbol
    public void onLocationChanged(AMapLocation location) {
                                  ^
  symbol:   class AMapLocation
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapFlutterLocationPlugin.java:8: error: package com.amap.api.location does not exist
import com.amap.api.location.AMapLocationClient;
                            ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/Utils.java:5: error: package com.amap.api.location does not exist
import com.amap.api.location.AMapLocation;
                            ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/Utils.java:15: error: cannot find symbol
    public static Map<String, Object> buildLocationResultMap(AMapLocation location) {
                                                             ^
  symbol:   class AMapLocation
  location: class Utils
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:20: error: cannot find symbol
    private AMapLocationClientOption locationOption = new AMapLocationClientOption();
                                                          ^
  symbol:   class AMapLocationClientOption
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:39: error: cannot find symbol
                    AMapLocationClient.updatePrivacyShow(mContext, true, true);
                    ^
  symbol:   variable AMapLocationClient
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:40: error: cannot find symbol
                    AMapLocationClient.updatePrivacyAgree(mContext, true);
                    ^
  symbol:   variable AMapLocationClient
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:46: error: cannot find symbol
                locationClient = new AMapLocationClient(mContext);
                                     ^
  symbol:   class AMapLocationClient
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:89: error: method does not override or implement a method from a supertype
    @Override
    ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:116: error: cannot find symbol
            locationOption = new AMapLocationClientOption();
                                 ^
  symbol:   class AMapLocationClientOption
  location: class AMapLocationClientImpl
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:134: error: package AMapLocationClientOption does not exist
                locationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.values()[(int) optionMap.get("locationMode")]);
                                                                       ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:142: error: package AMapLocationClientOption does not exist
                locationOption.setGeoLanguage(AMapLocationClientOption.GeoLanguage.values()[(int) optionMap.get("geoLanguage")]);
                                                                      ^
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapFlutterLocationPlugin.java:120: error: cannot find symbol
                AMapLocationClient.updatePrivacyShow(context, hasContains, hasShow);
                ^
  symbol:   variable AMapLocationClient
  location: class AMapFlutterLocationPlugin
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapFlutterLocationPlugin.java:124: error: cannot find symbol
                AMapLocationClient.updatePrivacyAgree(context, hasAgree);
                ^
  symbol:   variable AMapLocationClient
  location: class AMapFlutterLocationPlugin
/home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/Utils.java:19: error: cannot find symbol
            if (location.getErrorCode() == AMapLocation.LOCATION_SUCCESS) {
                                           ^
  symbol:   variable AMapLocation
  location: class Utils
22 errors

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':amap_flutter_location:compileReleaseJavaWithJavac'.
> Compilation failed; see the compiler output below.
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:20: error: cannot find symbol
      private AMapLocationClientOption locationOption = new AMapLocationClientOption();
              ^
    symbol:   class AMapLocationClientOption
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:21: error: cannot find symbol
      private AMapLocationClient locationClient = null;
              ^
    symbol:   class AMapLocationClient
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:90: error: cannot find symbol
      public void onLocationChanged(AMapLocation location) {
                                    ^
    symbol:   class AMapLocation
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/Utils.java:15: error: cannot find symbol
      public static Map<String, Object> buildLocationResultMap(AMapLocation location) {
                                                               ^
    symbol:   class AMapLocation
    location: class Utils
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:20: error: cannot find symbol
      private AMapLocationClientOption locationOption = new AMapLocationClientOption();
                                                            ^
    symbol:   class AMapLocationClientOption
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:39: error: cannot find symbol
                      AMapLocationClient.updatePrivacyShow(mContext, true, true);
                      ^
    symbol:   variable AMapLocationClient
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:40: error: cannot find symbol
                      AMapLocationClient.updatePrivacyAgree(mContext, true);
                      ^
    symbol:   variable AMapLocationClient
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:46: error: cannot find symbol
                  locationClient = new AMapLocationClient(mContext);
                                       ^
    symbol:   class AMapLocationClient
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:116: error: cannot find symbol
              locationOption = new AMapLocationClientOption();
                                   ^
    symbol:   class AMapLocationClientOption
    location: class AMapLocationClientImpl
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapFlutterLocationPlugin.java:120: error: cannot find symbol
                  AMapLocationClient.updatePrivacyShow(context, hasContains, hasShow);
                  ^
    symbol:   variable AMapLocationClient
    location: class AMapFlutterLocationPlugin
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapFlutterLocationPlugin.java:124: error: cannot find symbol
                  AMapLocationClient.updatePrivacyAgree(context, hasAgree);
                  ^
    symbol:   variable AMapLocationClient
    location: class AMapFlutterLocationPlugin
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/Utils.java:19: error: cannot find symbol
              if (location.getErrorCode() == AMapLocation.LOCATION_SUCCESS) {
                                             ^
    symbol:   variable AMapLocation
    location: class Utils
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:89: error: method does not override or implement a method from a supertype
      @Override
      ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:15: error: cannot find symbol
  public class AMapLocationClientImpl implements AMapLocationListener {
                                                 ^
    symbol: class AMapLocationListener
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:6: error: package com.amap.api.location does not exist
  import com.amap.api.location.AMapLocation;
                              ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:7: error: package com.amap.api.location does not exist
  import com.amap.api.location.AMapLocationClient;
                              ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:8: error: package com.amap.api.location does not exist
  import com.amap.api.location.AMapLocationClientOption;
                              ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:9: error: package com.amap.api.location does not exist
  import com.amap.api.location.AMapLocationListener;
                              ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapFlutterLocationPlugin.java:8: error: package com.amap.api.location does not exist
  import com.amap.api.location.AMapLocationClient;
                              ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/Utils.java:5: error: package com.amap.api.location does not exist
  import com.amap.api.location.AMapLocation;
                              ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:134: error: package AMapLocationClientOption does not exist
                  locationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.values()[(int) optionMap.get("locationMode")]);
                                                                         ^
  /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/plugins/amap_flutter_location/android/src/main/java/com/amap/flutter/location/AMapLocationClientImpl.java:142: error: package AMapLocationClientOption does not exist
                  locationOption.setGeoLanguage(AMapLocationClientOption.GeoLanguage.values()[(int) optionMap.get("geoLanguage")]);
                                                                        ^
  22 errors

* Try:
> Check your code and dependencies to fix the compilation error(s)
> Run with --scan to get full insights.

BUILD FAILED in 31s
Running Gradle task 'assembleRelease'...                           31.8s
Gradle task assembleRelease failed with exit code 1
Error: Process completed with exit code 1.