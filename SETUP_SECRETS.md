# Configuración de secretos (no commitear)

1. **Copia `.env.example` a `.env`** en la raíz y rellena con tus valores.
2. **Google Maps (Android):** Al hacer `flutter run` o build Android, Gradle necesita la clave. Opciones:
   - Exportar antes de ejecutar: `export GOOGLE_MAPS_API_KEY=$(grep GOOGLE_MAPS_API_KEY .env | cut -d= -f2)` y luego `flutter run`
   - O añadir en `android/local.properties` (ya está en .gitignore):  
     `google.maps.api.key=TU_CLAVE`
3. **Firebase:** Copia `android/app/google-services.json.example` a `android/app/google-services.json` y rellena con el archivo descargado de la consola de Firebase. No subas `google-services.json` a Git.
