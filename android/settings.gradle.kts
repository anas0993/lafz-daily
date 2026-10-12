pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // Local mirror first (egress proxy is unreliable for Gradle).
        maven { url = uri("file:///home/hatch/sdks/local-maven") }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
}

include(":app")

dependencyResolutionManagement {
    repositories {
        // Local mirror first (egress proxy is unreliable for Gradle).
        maven { url = uri("file:///home/hatch/sdks/local-maven") }
        google()
        mavenCentral()
    }
}
