// Define Kotlin version
val kotlin_version = "1.9.24"

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.docplan"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    buildFeatures {
        buildConfig = true
    }
    lint {
        checkReleaseBuilds = false
    }

    defaultConfig {
        applicationId = "com.example.docplan"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        multiDexEnabled = true

        manifestPlaceholders["appAuthRedirectScheme"] = "com.example.docplan"

        vectorDrawables.useSupportLibrary = true

        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
        
        // Memory optimization for Google Maps
        manifestPlaceholders["usesCleartextTraffic"] = "true"
        manifestPlaceholders["hardwareAccelerated"] = "true"
        manifestPlaceholders["largeHeap"] = "true"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // Replace with real release config
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            buildConfigField("boolean", "MAPS_DEBUG", "false")
        }

        getByName("debug") {
            isDebuggable = true
            versionNameSuffix = "-debug"
            buildConfigField("boolean", "MAPS_DEBUG", "true")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    packaging {
        resources {
            pickFirsts += listOf(
                "**/libc++_shared.so",
                "**/libjsc.so"
            )
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }

    lint {
        disable.add("InvalidPackage")
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Kotlin stdlib
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version")

    // Firebase Messaging & Analytics (Crashlytics Removed)
    implementation("com.google.firebase:firebase-messaging:24.1.2")
    implementation("com.google.firebase:firebase-analytics:22.1.2")

    // Google Maps & Location
    implementation("com.google.android.gms:play-services-maps:19.0.0")
    implementation("com.google.android.gms:play-services-location:21.3.0")
    implementation("com.google.android.gms:play-services-base:18.5.0")

    // Multidex
    implementation("androidx.multidex:multidex:2.0.1")

    // AndroidX core libraries
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.activity:activity-ktx:1.9.3")
    implementation("androidx.fragment:fragment-ktx:1.8.5")

    // Lifecycle
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-process:2.8.7")

    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.1")

    // Material Components
    implementation("com.google.android.material:material:1.12.0")

    // Debugging tools
    debugImplementation("com.squareup.leakcanary:leakcanary-android:2.14")

    // Networking
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    // JSON parsing
    implementation("com.google.code.gson:gson:2.11.0")

    // Image loading
    implementation("com.github.bumptech.glide:glide:4.16.0")

    // Permissions
    implementation("pub.devrel:easypermissions:3.0.0")
}

googleServices {
    disableVersionCheck = false
}

configurations.all {
    resolutionStrategy {
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.appcompat:appcompat:1.7.0")
    }
}

// Custom task to clean before build
tasks.register<Delete>("cleanBeforeBuild") {
    delete(rootProject.buildDir)
}

tasks.named("preBuild") {
    dependsOn("cleanBeforeBuild")
}
// Custom task to clean after build