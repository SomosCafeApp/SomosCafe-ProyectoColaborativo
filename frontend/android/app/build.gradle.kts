import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Claves y firma: se leen de archivos/variables locales (NO van a GitHub).
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

android {
    namespace = "com.somoscafeapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Requerido por flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.somoscafeapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Clave de Google Maps SDK para Android (se inyecta en el manifest).
        // Se define en android/local.properties (MAPS_API_KEY=...) o como
        // variable de entorno MAPS_API_KEY.
        manifestPlaceholders["MAPS_API_KEY"] =
            localProps.getProperty("MAPS_API_KEY")
                ?: System.getenv("MAPS_API_KEY")
                ?: ""
    }

    signingConfigs {
        // Solo se crea si existe android/key.properties.
        if (keyProps.getProperty("storeFile") != null) {
            create("release") {
                storeFile = rootProject.file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // La versión release SIEMPRE se firma con tu keystore de
            // subida (android/key.properties). Ya no se cae a la clave
            // de debug: Google Play rechaza esos paquetes.
            if (signingConfigs.findByName("release") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

// Si se intenta construir un release sin key.properties, el build se
// detiene con un mensaje claro (en vez de generar un APK/AAB mal firmado).
// Solo para pruebas locales puedes saltarte esto con la variable de
// entorno ALLOW_DEBUG_RELEASE=true (el resultado NO sirve para Play).
gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any {
        val n = it.name
        n.contains("Release") &&
            (n.startsWith("assemble") || n.startsWith("bundle") || n.startsWith("package"))
    }
    val hasReleaseKey = android.signingConfigs.findByName("release") != null
    if (buildsRelease && !hasReleaseKey && System.getenv("ALLOW_DEBUG_RELEASE") != "true") {
        throw GradleException(
            "Falta android/key.properties: no se puede firmar el release. " +
                "Crea tu keystore y el archivo key.properties (ver guía de firma)."
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Requerido por flutter_local_notifications.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Firebase: el plugin exige google-services.json y rompe el build si
// falta. Así la app sigue compilando antes de configurar Firebase;
// cuando agregues android/app/google-services.json se activa solo.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
