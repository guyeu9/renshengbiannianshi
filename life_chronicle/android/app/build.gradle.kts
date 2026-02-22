plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.suliuzhe.lifechronicle"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.suliuzhe.lifechronicle"
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
        }
    }

    packaging {
        jniLibs {
            pickFirsts.addAll(
                listOf(
                    "lib/arm64-v8a/libssl.so",
                    "lib/arm64-v8a/libcrypto.so",
                    "lib/armeabi-v7a/libssl.so",
                    "lib/armeabi-v7a/libcrypto.so"
                )
            )
        }
    }
}

flutter {
    source = "../.."
}

val amapSdkVersion = providers.gradleProperty("AMAP_SDK_VERSION").orElse("10.1.200").get()

dependencies {
    implementation("com.amap.api:3dmap:$amapSdkVersion")
    implementation("com.amap.api:location:6.4.9")
    implementation("com.amap.api:search:9.7.4")
}
