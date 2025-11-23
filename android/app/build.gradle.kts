plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

android {
    namespace = "com.example.chefleet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.chefleet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Read environment variables from .env file
        val envProperties = Properties()
        val envFile = rootProject.file("../.env")
        if (envFile.exists()) {
            envProperties.load(FileInputStream(envFile))
        }

        // Also read from local.properties as fallback
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localProperties.load(FileInputStream(localPropertiesFile))
        }

        // Set the Google Maps API key as a build config field and manifest placeholder
        // Priority: .env file > local.properties > empty string
        val mapsApiKey = envProperties.getProperty("MAPS_API_KEY")
            ?: localProperties.getProperty("GOOGLE_MAPS_API_KEY", "")

        // Debug output for troubleshooting
        println("Maps API key from .env: ${envProperties.getProperty("MAPS_API_KEY")}")
        println("Maps API key from local.properties: ${localProperties.getProperty("GOOGLE_MAPS_API_KEY")}")
        println("Final maps API key: $mapsApiKey")

        buildConfigField("String", "MAPS_API_KEY", "\"$mapsApiKey\"")
        
        // Set manifest placeholder for Google Maps API key
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
