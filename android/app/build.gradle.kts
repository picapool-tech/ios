import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


var localProperties =  Properties()
var localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    val reader = localPropertiesFile.reader(Charsets.UTF_8)
    localProperties.load(reader)
}

var projectDir = rootProject

val keyStoreProperties = Properties()
val keyStorePropertiesFile = rootProject.file("key.properties")
if (keyStorePropertiesFile.exists()) {
    val reader = keyStorePropertiesFile.reader(Charsets.UTF_8)
    keyStoreProperties.load(reader)
}

//def keystoreProperties = new Properties()
//def keystorePropertiesFile = rootProject.file('key.properties')
//if (keystorePropertiesFile.exists()) {
//    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
//}
//
//def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
//if (flutterVersionCode == null) {
//    flutterVersionCode = '1'
//}
//
//def flutterVersionName = localProperties.getProperty('flutter.versionName')
//if (flutterVersionName == null) {
//    flutterVersionName = '1.0'
//}


android {
    namespace = "com.picapool"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.picapool"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyStoreProperties["keyAlias"]?.toString()
            keyPassword = keyStoreProperties["keyPassword"]?.toString()
            storeFile = keyStoreProperties["storeFile"]?.let { file(it.toString()) }
            storePassword = keyStoreProperties["storePassword"]?.toString()
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
    implementation("com.google.android.gms:play-services-maps:19.2.0")
    implementation("com.google.android.gms:play-services-location:21.3.0")
    implementation("com.google.android.material:material:1.12.0")
}
