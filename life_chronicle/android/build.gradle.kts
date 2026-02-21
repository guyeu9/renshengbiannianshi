allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven {
            url = uri("https://maven.aliyun.com/repository/gaode")
            val aliyunUser = System.getenv("ALIYUN_MAVEN_USERNAME")
            val aliyunPassword = System.getenv("ALIYUN_MAVEN_PASSWORD")
            if (!aliyunUser.isNullOrBlank() && !aliyunPassword.isNullOrBlank()) {
                credentials {
                    username = aliyunUser
                    password = aliyunPassword
                }
            }
        }
        maven { url = uri("https://repo.amap.com/repository/maven-public") }
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
