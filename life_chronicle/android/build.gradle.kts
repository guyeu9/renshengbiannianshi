allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven {
            url = uri("https://maven.aliyun.com/repository/google")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/central")
        }
    }

    configurations.all {
        resolutionStrategy {
            // 强制约束 androidx.core 版本以兼容 Android Gradle Plugin 8.2.2
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
gradle.afterProject {
    if (!plugins.hasPlugin("com.android.library")) return@afterProject
    val androidExtension = extensions.findByName("android") ?: return@afterProject

    run {
        val method =
            androidExtension.javaClass.methods.firstOrNull { m ->
                (m.name == "compileSdkVersion" || m.name == "setCompileSdkVersion" || m.name == "setCompileSdk") &&
                    m.parameterTypes.size == 1 &&
                    (m.parameterTypes[0] == Int::class.javaPrimitiveType || m.parameterTypes[0] == Int::class.java)
            }
        if (method != null) {
            method.invoke(androidExtension, 35)
        }
    }

    val currentNamespace =
        androidExtension.javaClass.methods
            .firstOrNull { it.name == "getNamespace" && it.parameterTypes.isEmpty() && it.returnType == String::class.java }
            ?.invoke(androidExtension) as? String

    if (currentNamespace.isNullOrBlank()) {
        val manifestFile = file("src/main/AndroidManifest.xml")
        if (manifestFile.exists()) {
            val manifestText = manifestFile.readText()
            val match =
                Regex("package\\s*=\\s*\"([^\"]+)\"").find(manifestText)
            val manifestPackage = match?.groupValues?.getOrNull(1)
            if (!manifestPackage.isNullOrBlank()) {
                val setNamespace =
                    androidExtension.javaClass.methods.firstOrNull { m ->
                        (m.name == "setNamespace" || m.name == "namespace") &&
                            m.parameterTypes.size == 1 &&
                            m.parameterTypes[0] == String::class.java
                    }
                setNamespace?.invoke(androidExtension, manifestPackage)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
