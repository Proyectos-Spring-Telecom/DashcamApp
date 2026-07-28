# 1. Contexto de la solución

## 1.1 Descripción general

**Nombre del proyecto:** DashboardPro (paquete `dashboardpro`)  
**Descripción:** Monedero Digital de DashCamPay.

Aplicación Flutter multiplataforma (Android, iOS, Web) que funciona como monedero digital para el ecosistema DashCamPay: autenticación, gestión de monederos, transacciones (recargas, débitos, pagos QR), integración con NetPay para tokenización de tarjetas, transporte (zonas, rutas, variantes, monitoreo), reporte de extravíos y perfiles fiscales, entre otros.

---

## 1.2 Plataformas y dependencias clave

| Plataforma | Notas |
|------------|--------|
| **Android** | API key de Google Maps en `android/local.properties` (`google.maps.api.key`). |
| **iOS** | Configuración en Xcode para Maps y permisos. |
| **Web** | Google Maps JavaScript API: carga en `lib/main.dart` con `_ensureGoogleMapsScriptLoaded()` (un solo script, espera a `onLoad` antes de arrancar el mapa) y clave vía `--dart-define=GOOGLE_MAPS_API_KEY`. NetPayJS se referencia en `web/index.html` (CDN) para tokenización en navegador. |

**Dependencias principales:** Flutter SDK ≥3.4.1, Dio (HTTP), go_router, flutter_secure_storage, flutter_dotenv, google_maps_flutter, calendar_date_picker2, Syncfusion (charts, maps, PDF, etc.), quickalert, mobile_scanner, qr_flutter, geolocator, NFC (flutter_nfc_kit), number_pagination (^1.0.6, resuelto a 1.1.6), entre otras.

**Nota:** Firebase (core, Firestore) fue **eliminado** del proyecto; la app no depende de `google-services.json` ni de inicialización Firebase en `main.dart`.

---

## 1.3 Build y despliegue

| Plataforma | Configuración relevante |
|------------|-------------------------|
| **Web** | Build: `flutter build web --release --base-href /dashcampay/ --dart-define=GOOGLE_MAPS_API_KEY=<clave> --dart-define-from-file=.env`. Opcional: `--no-wasm-dry-run`. **Desarrollo local:** requiere proxy CORS (`dart run tool/dev_api_proxy.dart`) — ver §1.6. |
| **Android** | Plugin de Kotlin **2.3.0** en `android/settings.gradle`. API key de Google Maps en `android/local.properties` (`google.maps.api.key`). Compila sin Firebase/`google-services.json`. |
| **iOS** | Configuración en Xcode para Maps y permisos. |

**Variables de entorno:** centralizadas en `lib/core/env_config.dart` (`EnvConfig`). Prioridad: `--dart-define` > `.env` (flutter_dotenv) > valores por defecto. Plantillas en `.env.example`, `.env.development.example`, etc. Ver `SETUP_SECRETS.md`.

**Paginación (DataTables):** En `lib/view/plugin/dataTables/components/pagination_datagrid.dart` se usa el paquete `number_pagination` 1.1.6. La API actual del widget `NumberPagination` utiliza `totalPages`, `currentPage` y `visiblePagesCount` (no `pageTotal`, `pageInit`, `threshold` ni `controlButton`).

---

## 1.4 Arquitectura de capas

La solución mezcla patrones en función del módulo:

| Capa | Contenido típico | Ubicación |
|------|-------------------|-----------|
| **Presentación** | Pantallas, widgets, Blocs, Controllers (ChangeNotifier) | `lib/view/`, `lib/controller/`, `lib/widgets/` |
| **Dominio** | Contratos de repositorios, entidades, `Result<T>`, casos de uso (algunos módulos) | `lib/domain/` |
| **Datos** | Implementación de repositorios, datasources remotos, modelos de datos | `lib/data/` |
| **Servicios** | Llamadas HTTP (Dio), lógica de negocio expuesta a Blocs/Controllers | `lib/services/` |
| **Modelos** | DTOs / modelos de dominio compartidos (auth, monedero, transacciones, etc.) | `lib/model/` |
| **Infraestructura** | Interceptores (sesión), almacenamiento seguro, helpers | `lib/interceptors/`, `lib/services/secure_storage_service.dart`, `lib/utils/` |

- **Blocs:** exponen streams de estado y errores; consumen servicios (AuthService, MonederoService, ZonasService, etc.) o, en algunos flujos, repositorios.
- **Repositorios (dominio):** abstraen la fuente de datos; devuelven `Result<T>` y son implementados en `data/repositories`.
- **Datasources:** realizan las peticiones HTTP (o delegan en un servicio existente, como en transacciones/viajes del día).
- **Controllers:** por ejemplo `TransaccionesController` (ChangeNotifier) para viajes del día, reutilizando el mismo servicio/repositorio en varias pantallas.

---

## 1.5 Módulos y funcionalidades principales

| Módulo | Descripción | Servicios / Blocs principales |
|--------|-------------|-----------------------------|
| **Autenticación** | Login (token + refresh), perfil vía `/login/me`, registro, verificación de correo (**6 dígitos**), recuperación de contraseña, cambio de contraseña (semáforo de seguridad), foto de perfil | AuthService, AuthApiService, AuthBloc, SecureStorageService |
| **Monedero** | Wallet del pasajero, monederos activos, recargas, transacciones paginadas, lista de clientes/pasajeros/tipos pasajero, creación de monederos | MonederoService, MonederoBloc |
| **Transacciones / Viajes del día** | Listado de transacciones del día (POST /transacciones/paginado), filtro por tipo DEBITO y ubicación (lat/lng), Último viaje y Actividad en Dashboard, Códigos QR y Estadísticas | MonederoService (reutilizado), TransaccionesRemoteDataSource, TransaccionesRepository, TransaccionesController |
| **Transacciones débito QR** | Transacciones débito QR del día (endpoint específico paginado) | TransaccionQrDebitoService, TransaccionQrDebitoBloc |
| **NetPay** | Tokenización de tarjetas (WebView en móvil, NetPayJS directo en web vía `NetPayWebTokenizer`), cliente NetPay, asignación de tarjetas, recargas con token reutilizable (`paymentSource.source`) | NetPayService, NetPayTokenizationService, NetPayWebviewService, `netpay_web_tokenizer_web` / stub, NetPayBloc, NetPayTokenizationBloc |
| **Transporte (Movilidad Inteligente)** | Zonas, rutas, variantes, monitoreo, CP, mapa con geocercas/polylines. **Mapa:** solo se monta tras resolver ubicación (Geolocator); no hay “posición inicial” fija en ruta normal; doble zoom (contexto y acercamiento al marker del usuario). | Mismos servicios/blocs; UI en `lib/view/dashboard/transporte.dart` |
| **Clientes (público)** | Listado de clientes activos sin autenticación | ClienteRemoteDataSource, ClienteRepository, ClienteRepositoryImpl |
| **Extravío** | Reporte de extravío | ExtravioRemoteDataSource, ExtravioRepository, ExtravioRepositoryImpl, ExtravioBloc |
| **Tema** | Modo claro/oscuro según sistema o preferencia | ThemeBloc |
| **NFC / plataforma** | NFC (stub en web), detección de plataforma, helpers de dispositivo | NfcService, platform_detector, device_info_helper |

---

## 1.6 API backend y configuración

- **Base URL (desarrollo):** `https://dashcampay.com/apidev` — resuelta por `EnvConfig.apiBaseUrl` (plantilla `.env.development.example`).
- **Base URL (producción):** `https://dashcampay.com/api` — plantilla `.env.production.example` vía `--dart-define-from-file`.
- **Configuración:** `API_BASE_URL` y opcionalmente `AUTH_API_BASE_URL` vía `--dart-define-from-file=.env` o `--dart-define`. Si no se define `AUTH_API_BASE_URL`, auth usa la misma base que la API general.
- **Autenticación:** Bearer token en header `Authorization` para la mayoría de los endpoints.
- **Flujo de sesión:** `POST /login` devuelve solo `{ token, refreshToken }`. El perfil completo (rol, permisos, cliente, etc.) se obtiene con `GET /login/me`. Renovación automática con `POST /login/refresh` ante HTTP 401 (vía `SessionInterceptor` + `TokenRefreshService`).
- **Endpoints públicos (sin token):** `/login`, `/login/refresh`, `/register`, `/forgot-password`, `/resend-code`, `/verify-code`, `/clientes/public`.
- **Interceptores Dio:**
  - `SessionInterceptor`: refresh de token en 401, cierre de sesión si falla, delegación a `SessionManager`.
  - `RateLimitInterceptor`: HTTP 429 global — alerta QuickAlert “Demasiados intentos” y log debug `[HTTP 429]`.
- **Desarrollo Web (CORS):** en `localhost` + debug, `EnvConfig` redirige automáticamente a `http://127.0.0.1:8090/apidev`. El proxy local (`tool/dev_api_proxy.dart`) reenvía a `https://dashcampay.com/apidev` e inyecta cabeceras CORS. Android/iOS no requieren proxy.

---

## 1.7 Navegación y roles

- **Navegación:** GoRouter (`lib/widgets/routes/app_routes.dart`); rutas definidas en `RoutesName`.
- **Ruta inicial:** según si el usuario está logueado y su rol: no logueado → bienvenida; logueado y rol **Cajero** → POS; resto → Dashboard.
- **Rutas protegidas:** si no hay sesión, se redirige a login. Si hay sesión y se accede a login/register/bienvenida, se redirige a la ruta inicial según rol.
- **Rutas principales:** `/` (init), `/bienvenida`, `/login`, `/dashboard`, `/pos`, `/codigos-qr`, `/transacciones`, `/transporte`, `/ingresar-monto`, `/monederos`, `/perfil`, `/metodos-pago`, `/transporte`, `/googleMaps`, entre otras.

---

## 1.8 Seguridad y persistencia

- **Token, refresh token y usuario:** persistidos con `SecureStorageService` (flutter_secure_storage). Tras login/refresh, `AuthBloc.applyRefreshedTokens()` guarda tokens y obtiene perfil con `GET /login/me` (fallback a datos del JWT si el endpoint no responde).
- **Contraseñas:** reglas compartidas en `lib/utils/password_rules.dart` (12–16 caracteres, minúscula, número, símbolo, sin espacios). Widget visual `PasswordSecurityMeter` en registro y cambio de contraseña.
- **Expiración de sesión:** manejada por `SessionManager` y `SessionInterceptor` (refresh automático en 401); la UI puede mostrar alertas (QuickAlert) y redirigir a login.
- **Rate limiting (429):** `RateLimitInterceptor` muestra alerta amigable al usuario y evita alertas duplicadas simultáneas.

---

## 1.9 Estructura de carpetas relevante (raíz lib/)

```
lib/
├── core/                # EnvConfig, env_loader (dotenv)
├── controller/          # Blocs y Controllers (AuthBloc, MonederoBloc, TransaccionesController, etc.)
├── data/                # Datasources, repository impl, modelos de data (cliente, extravio, transacciones)
├── domain/              # Repositories (abstract), entities, Result, use cases
├── model/               # Modelos compartidos (auth, monedero, transaccion, netpay, zonas, etc.)
├── services/            # Auth, AuthApiService, Monedero, NetPay, Zonas, Rutas, Variantes, Monitoreo, Direccion, NFC, etc.
├── interceptors/        # SessionInterceptor, RateLimitInterceptor (Dio)
├── view/                # Pantallas: dashboard, authentications, plugin (charts, maps, calendar), components
├── widgets/             # Rutas (app_routes, routes_name), password_security_meter, scaffold_key, universal_dash, common
├── utils/               # password_rules, date_formatter, location_helper, platform_detector, etc.
├── dashboardpro.dart    # Barrel file (exports)
└── main.dart            # Inicialización (loadAppEnv, AuthBloc, carga de Google Maps JS en web, runApp)
```

---

## 1.10 Flujos de datos representativos

1. **Login:** UI → AuthBloc.login → AuthApiService.post('/login') → `{ token, refreshToken }` → AuthBloc.applyRefreshedTokens → GET /login/me → SecureStorage → GoRouter redirige según rol.
2. **Refresh de sesión:** Dio recibe 401 → SessionInterceptor → TokenRefreshService → POST /login/refresh → reintento con nuevo token; si falla → SessionManager cierra sesión.
3. **Monedero / transacciones general:** UI → MonederoBloc → MonederoService (Dio + EnvConfig.apiBaseUrl) → API → streams actualizados.
4. **Viajes del día:** UI → TransaccionesController → TransaccionesRepository → TransaccionesRemoteDataSource → MonederoService.obtenerListaTransacciones → POST /transacciones/paginado → filtrado en UI.
5. **Clientes públicos:** ClienteBloc → ClienteRepositoryImpl → ClienteRemoteDataSource.get('/clientes/public').
6. **Extravío:** ExtravioBloc → ExtravioRepository → ExtravioRemoteDataSource → API.
7. **Registro:** formulario con validación de contraseña (PasswordRules + PasswordSecurityMeter), fecha de nacimiento vía CalendarDatePicker2 (diálogo responsive), verificación de correo con código de **6 dígitos**.

---

## 1.11 Evolución reciente (8 de julio de 2026)

Cambios de contexto alineados con el código actual:

### Configuración y API

- **EnvConfig:** centraliza `API_BASE_URL`, `AUTH_API_BASE_URL`, `GOOGLE_MAPS_API_KEY`, `NETPAY_PUBLIC_API_KEY` y `APP_ENV`. Prioridad: `--dart-define` > `.env` > default.
- **Base URL:** entornos **`apidev`** (desarrollo) y **`api`** (producción). Ver plantillas `.env.*.example`.
- **Proxy Web (CORS):** `tool/dev_api_proxy.dart` en puerto 8090; activo automáticamente en Flutter Web + debug + localhost. Script de atajo: `scripts/run_web_dev.sh`. Documentación en `SETUP_SECRETS.md`.
- **Firebase eliminado:** sin dependencias ni init en `main.dart`; Android compila sin `google-services.json`.

### Autenticación

- **Login desacoplado del perfil:** `POST /login` → `{ token, refreshToken }`; perfil con `GET /login/me`.
- **AuthApiService:** cliente Dio dedicado para login/refresh (sin SessionInterceptor, evita ciclos).
- **Refresh automático:** `SessionInterceptor` + `TokenRefreshService` ante HTTP 401.
- **Verificación de correo:** código de **6 dígitos** (`email_verify.dart`).
- **Contraseñas:** `PasswordRules` + `PasswordSecurityMeter` en registro y cambio de contraseña (12–16 chars, minúscula, número, símbolo, sin espacios).
- **HTTP 429:** `RateLimitInterceptor` global con QuickAlert “Demasiados intentos”.

### Registro (UI)

- **Calendario fecha de nacimiento:** `CalendarDatePicker2` con diálogo responsive — ancho según `MediaQuery`, modo compacto en pantallas estrechas (`disableMonthPicker`, meses abreviados, tipografías reducidas) para evitar overflow del selector mes/año.

---

## 1.12 Evolución anterior (27 de abril de 2026)

Cambios de contexto alineados con el código actual:

### Movilidad Inteligente y Google Maps

- **Ubicación primero:** el `GoogleMap` se muestra solo cuando ya existe `LatLng` de **Geolocator** (o fallback extremo si GPS/permisos no están disponibles). Mientras tanto, la pantalla muestra “Obteniendo tu ubicación…”, sin centrar en una ciudad fija.
- **Cámara y marker del usuario:** zoom de contexto inicial (~15) y, tras pintar el marker, **acercamiento animado** (~17,35) al mismo punto para que el entorno se lea mejor.
- **Carga del mapa en web:** evitar condiciones de carrera con `window.google.maps`; el arranque espera a que el script de la API termine de cargar.
- **Ciclo de vida del controlador:** no se invoca `dispose()` manualmente sobre `GoogleMapController` (el plugin lo gestiona; en web un `dispose` manual provocaba fallos).
- **Overlay “Cargando mapa…”:** se muestra con **debounce** (p. ej. ~350–450 ms) solo si el callback `onMapCreated` tarda, para no tapar el mapa en cargas rápidas.

### NetPay (monedero / recargas)

- **Web:** tokenización con NetPayJS en el navegador; **móvil/desktop no web:** `webview_flutter` con HTML de `assets/html/netpay_tokenization.html`.
- **Tarjeta guardada vs uso único:** en tokenización, `saveCard` controla `vault` / `simpleUse` en NetPayJS; en recargas se envía al backend el token reutilizable del **`paymentSource.source`**, no el `card.token` de un solo uso (evita “This token has already been used”).
- **UX en web:** ante fallos de red o carga de NetPayJS, mensaje informativo vía `QuickAlert` (sin recuadro de error rojo inline en el flujo de tokenización afectado).

### Claves y configuración

- **Variables de entorno:** `EnvConfig` + `.env` / `--dart-define-from-file` para API, Maps y NetPay. Ver `SETUP_SECRETS.md`.
- **Google Maps (web):** `GOOGLE_MAPS_API_KEY` con `--dart-define` o `.env` (p. ej. leyendo `google.maps.api.key` de `android/local.properties`).
- **NetPay:** llave pública `NETPAY_PUBLIC_API_KEY` vía `EnvConfig.netpayPublicApiKey` (solo `pk_*` en cliente).

---

Este documento describe el contexto de **toda** la solución; los contratos detallados por capa y módulo se encuentran en `02_CONTRATOS_SOLUCION.md`.
