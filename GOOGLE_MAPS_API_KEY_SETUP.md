# Configuración de Google Maps API Key

Este proyecto requiere una clave de API de Google Maps para funcionar correctamente. Por razones de seguridad, la clave **NO** debe estar hardcodeada en el código fuente.

## Configuración para Android

### Opción 1: Usando local.properties (Recomendado)

1. Abre el archivo `android/local.properties` (si no existe, créalo)
2. Agrega la siguiente línea:
   ```
   google.maps.api.key=TU_CLAVE_DE_API_AQUI
   ```
3. El archivo `local.properties` ya está en `.gitignore`, por lo que no se subirá al repositorio

### Opción 2: Usando Variable de Entorno

1. Define la variable de entorno antes de compilar:
   ```bash
   export GOOGLE_MAPS_API_KEY=TU_CLAVE_DE_API_AQUI
   flutter build apk
   ```

## Configuración para iOS

### Opción 1: Usando GoogleMapsApiKey.xcconfig (Recomendado)

1. Abre el archivo `ios/Flutter/GoogleMapsApiKey.xcconfig`
2. Agrega la siguiente línea:
   ```
   GOOGLE_MAPS_API_KEY=TU_CLAVE_DE_API_AQUI
   ```
3. **IMPORTANTE**: Este archivo está en `.gitignore`, así que no se subirá al repositorio si contiene la clave real

### Opción 2: Usando Variable de Entorno

1. Define la variable de entorno antes de compilar:
   ```bash
   export GOOGLE_MAPS_API_KEY=TU_CLAVE_DE_API_AQUI
   flutter build ios
   ```

## Verificación

Después de configurar la clave, verifica que funciona:

- **Android**: Ejecuta `flutter run` y verifica que no aparezca un error sobre la clave faltante
- **iOS**: Ejecuta `flutter run` y verifica que no aparezca un error sobre la clave faltante

## Seguridad

⚠️ **IMPORTANTE**: 
- Nunca subas archivos que contengan tu clave de API real al repositorio
- Si accidentalmente subiste una clave, revócala inmediatamente en la consola de Google Cloud
- Considera restringir la clave de API por dominio/IP en la consola de Google Cloud para mayor seguridad

## Obtener una Clave de API

Si no tienes una clave de API de Google Maps:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la API de Maps SDK for Android y Maps SDK for iOS
4. Ve a "Credenciales" y crea una nueva clave de API
5. Configura las restricciones de la clave según tus necesidades

