import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties файлын окуу үчүн код
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    // ЖАҢЫЛОО: Пакеттин атын дал келтирдик (Мурун com.demal.app.service болчу)
    namespace = "com.appitcompany.billbuddy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ЖАҢЫЛОО: Билдирүү пакетин өчүргөнүбүз үчүн desugaring өчүрүлдү
        isCoreLibraryDesugaringEnabled = false
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

       signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = (keystoreProperties["storeFile"] as? String)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

        buildTypes {
        getByName("release") {
            // Релиздик ачкычты туташтыруу
            signingConfig = signingConfigs.getByName("release")
            
            // ЖАҢЫ СИНТАКСИС (Катаны ушул жер оңдойт):
            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }


    defaultConfig {
        applicationId = "com.appitcompany.billbuddy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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

// ЖАҢЫЛОО: Блок туура жабылып, бош dependencies кошулду
dependencies {
}
