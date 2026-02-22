allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven {
            url = uri("https://maven.aliyun.com/repository/gaode")
            val amapUser =
                System.getenv("AMAP_MAVEN_USERNAME")
                    ?: System.getenv("ALIYUN_MAVEN_USERNAME")
                    ?: providers.gradleProperty("AMAP_MAVEN_USERNAME").orNull
                    ?: providers.gradleProperty("ALIYUN_MAVEN_USERNAME").orNull
            val amapPassword =
                System.getenv("AMAP_MAVEN_PASSWORD")
                    ?: System.getenv("ALIYUN_MAVEN_PASSWORD")
                    ?: providers.gradleProperty("AMAP_MAVEN_PASSWORD").orNull
                    ?: providers.gradleProperty("ALIYUN_MAVEN_PASSWORD").orNull
            if (!amapUser.isNullOrBlank() && !amapPassword.isNullOrBlank()) {
                credentials {
                    username = amapUser
                    password = amapPassword
                }
            }
        }
        maven {
            url = uri("https://repo.amap.com/repository/maven-public")
            val amapUser =
                System.getenv("AMAP_MAVEN_USERNAME")
                    ?: System.getenv("ALIYUN_MAVEN_USERNAME")
                    ?: providers.gradleProperty("AMAP_MAVEN_USERNAME").orNull
                    ?: providers.gradleProperty("ALIYUN_MAVEN_USERNAME").orNull
            val amapPassword =
                System.getenv("AMAP_MAVEN_PASSWORD")
                    ?: System.getenv("ALIYUN_MAVEN_PASSWORD")
                    ?: providers.gradleProperty("AMAP_MAVEN_PASSWORD").orNull
                    ?: providers.gradleProperty("ALIYUN_MAVEN_PASSWORD").orNull
            if (!amapUser.isNullOrBlank() && !amapPassword.isNullOrBlank()) {
                credentials {
                    username = amapUser
                    password = amapPassword
                }
            }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
