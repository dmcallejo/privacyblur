import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "de.mathema.privacyblur"
    // permission_handler_android needs API 37; compileSdk is backward compatible.
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        resValues = true
    }

    flavorDimensions += "flavor-type"
    productFlavors {
        create("foss") {
            dimension = "flavor-type"
            applicationId = "de.mathema.privacyblur"
            versionNameSuffix = "-foss"
            resValue("string", "app_name", "PrivacyBlur FOSS")
        }
        create("full") {
            dimension = "flavor-type"
            applicationId = "de.mathema.privacyblur"
            versionNameSuffix = "-full"
            resValue("string", "app_name", "PrivacyBlur")
        }
    }

    lint {
        disable += "InvalidPackage"
        checkReleaseBuilds = false
    }

    defaultConfig {
        applicationId = "de.mathema.privacyblur"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Sign with the release key when key.properties exists, otherwise
            // fall back to the debug key so release builds still work locally.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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

dependencies {
    // Face detection is only part of the "full" flavor (not FOSS).
    "fullImplementation"("com.google.mlkit:face-detection:16.1.1")
}
