plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.davidosunsakin.stays_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.davidosunsakin.stays_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // AGP 8+ disables generated resource values unless asked; the launcher
    // label below is one.
    buildFeatures {
        resValues = true
    }

    // One flavor per tenant. Each gets its own applicationId, so Android keeps
    // the two installs (and their secure storage) completely apart. The label
    // is native launcher metadata; inside the app the name comes from the
    // runtime config.
    flavorDimensions += "tenant"
    productFlavors {
        create("alpine") {
            dimension = "tenant"
            applicationIdSuffix = ".alpine"
            resValue("string", "app_name", "Alpine Stays")
        }
        create("riviera") {
            dimension = "tenant"
            applicationIdSuffix = ".riviera"
            resValue("string", "app_name", "Riviera Rentals")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
