# Guía de firma y publicación en Google Play — SomosCafe App

ID de la app: `com.somoscafeapp` · Versión actual: `1.0.0+1`

## 0. Una sola vez: configuración por el nuevo ID

1. **Firebase**: consola → proyecto `somoscafeapp-9e877` → Configuración → *Agregar app* → Android → paquete `com.somoscafeapp`. Descarga el nuevo `google-services.json` y reemplaza `frontend/android/app/google-services.json`.
2. **Huellas SHA**: en la app de Firebase agrega SHA-1 y SHA-256 de (a) tu keystore de subida y (b) más adelante, la clave de firma de Play (Play Console → Integridad de la app).
3. **Google Sign-In**: en Google Cloud (el proyecto que tiene el cliente web `868387662732-…`) crea un *ID de cliente OAuth* tipo **Android** con paquete `com.somoscafeapp` y la SHA-1. Hazlo para la SHA-1 de subida, la de debug y la de Play.
4. **Google Maps / Geocoding**: si tus claves tienen restricción de aplicación Android, agrega `com.somoscafeapp` + SHA-1.

## 1. Crear el keystore de subida

Windows (PowerShell):
```
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Mac/Linux:
```
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Guarda el `.jks` y las contraseñas en un lugar seguro (nunca en Git). Para ver las huellas:
```
keytool -list -v -keystore <ruta>/upload-keystore.jks -alias upload
```

## 2. `frontend/android/key.properties` (ignorado por Git)
```
storePassword=TU_CONTRASEÑA
keyPassword=TU_CONTRASEÑA
keyAlias=upload
storeFile=C:/Users/TU_USUARIO/upload-keystore.jks
```

## 3. Clave de Google Maps del manifest
En `frontend/android/local.properties` agrega: `MAPS_API_KEY=tu_clave` (o define la variable de entorno `MAPS_API_KEY`).

## 4. Compilar
```
cd frontend
flutter clean
flutter pub get
flutter build appbundle --release --dart-define=GEOCODING_API_KEY=tu_clave_geocoding
```
Resultado: `build/app/outputs/bundle/release/app-release.aab` (es lo que se sube a Play).

APK firmado (pruebas o descarga directa):
```
flutter build apk --release --dart-define=GEOCODING_API_KEY=tu_clave_geocoding
```
Resultado: `build/app/outputs/flutter-apk/app-release.apk`.

Cada nueva subida debe tener un número de build mayor: `version: 1.0.1+2` en `pubspec.yaml` (y actualiza `AppInfo.version` en `lib/core/config/app_info.dart`).

## 5. Play Console
- Crear la app → Android, español, gratuita.
- Activar **Play App Signing** y subir el `.aab` (primero en *Prueba interna*).
- **Política de privacidad (URL)**: activa GitHub Pages (Settings → Pages → rama `main`, carpeta `/docs`) y usa `…/privacidad.html`.
- **Eliminación de cuenta (URL)**: `…/eliminar-cuenta.html`.
- **Seguridad de los datos**: declara nombre, correo, teléfono, fecha de nacimiento, direcciones, fotos, mensajes (ChatBot) e identificadores de dispositivo (notificaciones); datos cifrados en tránsito; el usuario puede pedir su eliminación.
- Permisos: micrófono (dictado del ChatBot) y notificaciones.
- Clasificación de contenido y público objetivo: mayores de 18 años.
- Si tu cuenta de desarrollador es personal y nueva, Play puede exigir una prueba cerrada con testers durante 14 días antes de producción: verifícalo en Play Console.
