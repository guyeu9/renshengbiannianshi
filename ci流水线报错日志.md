Run flutter build apk --release
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 93.0.0 (96.0.0 available)
! amap_flutter_base 3.0.0 from path plugins/amap_flutter_base (overridden)
! amap_flutter_location 3.0.1 from path plugins/amap_flutter_location (overridden)
! amap_flutter_map 3.0.0 from path plugins/amap_flutter_map (overridden)
  analyzer 10.0.1 (10.2.0 available)
  archive 3.6.1 (4.0.9 available)
  build_config 1.2.0 (1.3.0 available)
  connectivity_plus 5.0.2 (7.0.0 available)
  connectivity_plus_platform_interface 1.2.4 (2.0.1 available)
  device_info_plus 9.1.2 (12.3.0 available)
  flutter_lints 5.0.0 (6.0.0 available)
  flutter_local_notifications 18.0.1 (20.1.0 available)
  flutter_local_notifications_linux 5.0.0 (7.0.0 available)
  flutter_local_notifications_platform_interface 8.0.0 (10.0.0 available)
  flutter_riverpod 2.6.1 (3.2.1 available)
  flutter_secure_storage 9.2.4 (10.0.0 available)
  flutter_secure_storage_linux 1.2.3 (3.0.0 available)
  flutter_secure_storage_macos 3.1.3 (4.0.0 available)
  flutter_secure_storage_platform_interface 1.1.2 (2.0.1 available)
  flutter_secure_storage_web 1.2.1 (2.1.0 available)
  flutter_secure_storage_windows 3.1.2 (4.1.0 available)
  image 3.3.0 (4.8.0 available)
  js 0.6.7 (0.7.2 available)
  lints 5.1.1 (6.1.0 available)
  meta 1.17.0 (1.18.1 available)
  mime 1.0.6 (2.0.0 available)
  pdf 3.8.4 (3.11.3 available)
  permission_handler 11.4.0 (12.0.1 available)
  permission_handler_android 12.1.0 (13.0.1 available)
  pointycastle 3.9.1 (4.0.0 available)
  riverpod 2.6.1 (3.2.1 available)
  share_plus 7.2.2 (12.0.1 available)
  share_plus_platform_interface 3.4.0 (6.1.0 available)
  sqlite3 2.9.4 (3.1.6 available)
  sqlite3_flutter_libs 0.5.41 (0.6.0+eol available)
  timezone 0.10.1 (0.11.0 available)
  vibration 2.1.0 (3.1.7 available)
  vibration_platform_interface 0.0.3 (0.1.1 available)
  win32 5.15.0 (6.0.0 available)
  win32_registry 1.1.5 (3.0.0 available)
  workmanager 0.5.2 (0.9.0+3 available)
Got dependencies!
38 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Upgrading build.gradle
Running Gradle task 'assembleRelease'...                        
Checking the license for package NDK (Side by side) 27.0.12077973 in /usr/local/lib/android/sdk/licenses
License for package NDK (Side by side) 27.0.12077973 accepted.
Preparing "Install NDK (Side by side) 27.0.12077973 v.27.0.12077973".
"Install NDK (Side by side) 27.0.12077973 v.27.0.12077973" ready.
Installing NDK (Side by side) 27.0.12077973 in /usr/local/lib/android/sdk/ndk/27.0.12077973
"Install NDK (Side by side) 27.0.12077973 v.27.0.12077973" complete.
"Install NDK (Side by side) 27.0.12077973 v.27.0.12077973" finished.
Warning: The plugin flutter_plugin_android_lifecycle requires Android SDK version 36 or higher.
For more information about build configuration, see https://flutter.dev/to/review-gradle-config.
Warning: The plugin image_picker_android requires Android SDK version 36 or higher.
For more information about build configuration, see https://flutter.dev/to/review-gradle-config.
Warning: The plugin path_provider_android requires Android SDK version 36 or higher.
For more information about build configuration, see https://flutter.dev/to/review-gradle-config.
Warning: The plugin url_launcher_android requires Android SDK version 36 or higher.
For more information about build configuration, see https://flutter.dev/to/review-gradle-config.
Warning: The plugin webview_flutter_android requires Android SDK version 36 or higher.
For more information about build configuration, see https://flutter.dev/to/review-gradle-config.
Your project is configured to compile against Android SDK 35, but the following plugin(s) require to be compiled against a higher Android SDK version:
- flutter_plugin_android_lifecycle compiles against Android SDK 36
- image_picker_android compiles against Android SDK 36
- path_provider_android compiles against Android SDK 36
- url_launcher_android compiles against Android SDK 36
- webview_flutter_android compiles against Android SDK 36
Fix this issue by compiling against the highest Android SDK version (they are backward compatible).
Add the following to /home/runner/work/renshengbiannianshi/renshengbiannianshi/life_chronicle/android/app/build.gradle:
    android {
        compileSdk = 36
        ...
    }
Checking the license for package Android SDK Platform 33 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Platform 33 accepted.
Preparing "Install Android SDK Platform 33 (revision 3)".
"Install Android SDK Platform 33 (revision 3)" ready.
Installing Android SDK Platform 33 in /usr/local/lib/android/sdk/platforms/android-33
"Install Android SDK Platform 33 (revision 3)" complete.
"Install Android SDK Platform 33 (revision 3)" finished.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 23400 bytes (98.6% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Note: Some input files use unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.
FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:checkReleaseAarMetadata'.
> A failure occurred while executing com.android.build.gradle.internal.tasks.CheckAarMetadataWorkAction
   > 10 issues were found when checking AAR metadata:
       1.  Dependency 'androidx.browser:browser:1.9.0' requires libraries and applications that
           depend on it to compile against version 36 or later of the
           Android APIs.
           :app is currently compiled against android-35.
           Also, the maximum recommended compile SDK version for Android Gradle
           plugin 8.2.2 is 34.
           Recommended action: Update this project's version of the Android Gradle
           plugin to one that supports 36, then update this project to use
           compileSdk of at least 36.
           Note that updating a library or application's compileSdk (which
           allows newer APIs to be used) can be done separately from updating
           targetSdk (which opts the app in to new runtime behavior) and
           minSdk (which determines which devices the app can be installed
           on).
       2.  Dependency 'androidx.browser:browser:1.9.0' requires Android Gradle plugin 8.9.1 or higher.
           This build currently uses Android Gradle plugin 8.2.2.
       3.  Dependency 'androidx.activity:activity:1.12.4' requires libraries and applications that
           depend on it to compile against version 36 or later of the
           Android APIs.
           :app is currently compiled against android-35.
           Also, the maximum recommended compile SDK version for Android Gradle
           plugin 8.2.2 is 34.
           Recommended action: Update this project's version of the Android Gradle
           plugin to one that supports 36, then update this project to use
           compileSdk of at least 36.
           Note that updating a library or application's compileSdk (which
           allows newer APIs to be used) can be done separately from updating
           targetSdk (which opts the app in to new runtime behavior) and
           minSdk (which determines which devices the app can be installed
           on).
       4.  Dependency 'androidx.activity:activity:1.12.4' requires Android Gradle plugin 8.9.1 or higher.
           This build currently uses Android Gradle plugin 8.2.2.
       5.  Dependency 'androidx.core:core-ktx:1.17.0' requires libraries and applications that
           depend on it to compile against version 36 or later of the
           Android APIs.
           :app is currently compiled against android-35.
           Also, the maximum recommended compile SDK version for Android Gradle
           plugin 8.2.2 is 34.
           Recommended action: Update this project's version of the Android Gradle
           plugin to one that supports 36, then update this project to use
           compileSdk of at least 36.
           Note that updating a library or application's compileSdk (which
           allows newer APIs to be used) can be done separately from updating
           targetSdk (which opts the app in to new runtime behavior) and
           minSdk (which determines which devices the app can be installed
           on).
       6.  Dependency 'androidx.core:core-ktx:1.17.0' requires Android Gradle plugin 8.9.1 or higher.
           This build currently uses Android Gradle plugin 8.2.2.
       7.  Dependency 'androidx.core:core:1.17.0' requires libraries and applications that
           depend on it to compile against version 36 or later of the
           Android APIs.
           :app is currently compiled against android-35.
           Also, the maximum recommended compile SDK version for Android Gradle
           plugin 8.2.2 is 34.
           Recommended action: Update this project's version of the Android Gradle
           plugin to one that supports 36, then update this project to use
           compileSdk of at least 36.
           Note that updating a library or application's compileSdk (which
           allows newer APIs to be used) can be done separately from updating
           targetSdk (which opts the app in to new runtime behavior) and
           minSdk (which determines which devices the app can be installed
           on).
       8.  Dependency 'androidx.core:core:1.17.0' requires Android Gradle plugin 8.9.1 or higher.
           This build currently uses Android Gradle plugin 8.2.2.
       9.  Dependency 'androidx.navigationevent:navigationevent-android:1.0.2' requires libraries and applications that
           depend on it to compile against version 36 or later of the
           Android APIs.
           :app is currently compiled against android-35.
           Also, the maximum recommended compile SDK version for Android Gradle
           plugin 8.2.2 is 34.
           Recommended action: Update this project's version of the Android Gradle
           plugin to one that supports 36, then update this project to use
           compileSdk of at least 36.
           Note that updating a library or application's compileSdk (which
           allows newer APIs to be used) can be done separately from updating
           targetSdk (which opts the app in to new runtime behavior) and
           minSdk (which determines which devices the app can be installed
           on).
      10.  Dependency 'androidx.navigationevent:navigationevent-android:1.0.2' requires Android Gradle plugin 8.9.1 or higher.
           This build currently uses Android Gradle plugin 8.2.2.
* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.
BUILD FAILED in 4m 16s
Running Gradle task 'assembleRelease'...                          256.7s
Gradle task assembleRelease failed with exit code 1
Error: Process completed with exit code 1.