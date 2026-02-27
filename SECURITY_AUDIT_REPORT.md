# Reporte de auditoría de seguridad — PASO 1

## 1. Archivos sensibles actualmente trackeados por Git

```
android/app/google-services.json   ← CONTIENE api_key (Firebase/Google)
android/gradle.properties
android/gradle/wrapper/gradle-wrapper.properties
lib/widgets/routes/scaffold_key.dart  ← No es secreto (ValueKey de Flutter)
```

- **android/local.properties**: NO está trackeado (está en `android/.gitignore`).
- **.env**: No existe aún; no estaba en .gitignore.

## 2. API keys y URLs hardcodeadas en el código

| Ubicación | Tipo | Valor/Detalle |
|-----------|------|----------------|
| `lib/services/netpay_webview_service.dart` | NetPay API key | `pk_netpay_JGFtQNUFIENMlhkoBXdgiozmQ` (línea 18) |
| `lib/services/auth_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/monedero_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/monitoreo_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/zonas_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/rutas_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/variantes_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/direccion_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/netpay_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/services/transaccion_qr_debito_service.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/data/datasources/extravio_remote_datasource.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `lib/data/datasources/cliente_remote_datasource.dart` | baseUrl | `https://dashcampay.com/apidev` |
| `android/app/build.gradle` | Google Maps key | Lee de local.properties o GOOGLE_MAPS_API_KEY (no hardcodeada, pero falla si falta) |
| `android/app/google-services.json` | Firebase/Google key | `AIzaSyDummyKeyForDevelopmentOnly` |

## 3. Estado actual del .gitignore

- **Raíz**: No incluye `.env`, `*.env`, `android/local.properties`, `android/app/google-services.json`, `key.properties`, `*.keystore`, `*.jks`. Incluye `.dart_tool/`, `build/`, `.idea/`, etc.
- **android/.gitignore**: Incluye `/local.properties`, `key.properties`, `**/*.keystore`, `**/*.jks`. No incluye `google-services.json`.

---

*Este reporte se generó antes de aplicar las correcciones. Los pasos siguientes implementan las medidas de seguridad.*
