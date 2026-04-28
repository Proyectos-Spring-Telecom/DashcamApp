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

**Dependencias principales:** Flutter SDK ≥3.4.1, Dio (HTTP), go_router, flutter_secure_storage, Firebase (core, Firestore), google_maps_flutter, Syncfusion (charts, maps, PDF, etc.), quickalert, mobile_scanner, qr_flutter, geolocator, NFC (flutter_nfc_kit), number_pagination (^1.0.6, resuelto a 1.1.6), entre otras.

---

## 1.3 Build y despliegue

| Plataforma | Configuración relevante |
|------------|-------------------------|
| **Web** | Build: `flutter build web --release --base-href /dashcampay/ --dart-define=GOOGLE_MAPS_API_KEY=<clave>`. Opcional: `--no-wasm-dry-run` para suprimir avisos Wasm. La API key se puede leer de `android/local.properties` con `grep 'google.maps.api.key' android/local.properties \| cut -d= -f2`. |
| **Android** | Plugin de Kotlin **2.3.0** en `android/settings.gradle` (compatible con kotlin-stdlib 2.3.x). API key de Google Maps en `android/local.properties` (`google.maps.api.key`). |
| **iOS** | Configuración en Xcode para Maps y permisos. |

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
| **Autenticación** | Login, registro, verificación de correo, recuperación de contraseña, cambio de contraseña, foto de perfil | AuthService, AuthBloc, SecureStorageService |
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

## 1.6 API backend

- **Base URL:** `https://dashcampay.com/apidev`
- **Autenticación:** Bearer token en header `Authorization` para la mayoría de los endpoints.
- **Endpoints públicos (sin token):** login, register, forgot-password, resend-code, verify-code, `clientes/public`.
- **Interceptor:** `SessionInterceptor` (Dio) detecta respuestas que indican sesión inválida y delega en `SessionManager` para cerrar sesión (por ejemplo redirección a login).

---

## 1.7 Navegación y roles

- **Navegación:** GoRouter (`lib/widgets/routes/app_routes.dart`); rutas definidas en `RoutesName`.
- **Ruta inicial:** según si el usuario está logueado y su rol: no logueado → bienvenida; logueado y rol **Cajero** → POS; resto → Dashboard.
- **Rutas protegidas:** si no hay sesión, se redirige a login. Si hay sesión y se accede a login/register/bienvenida, se redirige a la ruta inicial según rol.
- **Rutas principales:** `/` (init), `/bienvenida`, `/login`, `/dashboard`, `/pos`, `/codigos-qr`, `/transacciones`, `/transporte`, `/ingresar-monto`, `/monederos`, `/perfil`, `/metodos-pago`, `/transporte`, `/googleMaps`, entre otras.

---

## 1.8 Seguridad y persistencia

- **Token y usuario:** persistidos con `SecureStorageService` (flutter_secure_storage); el token se envía en las peticiones que no son públicas.
- **Expiración de sesión:** manejada por `SessionManager` y `SessionInterceptor`; la UI puede mostrar alertas (p. ej. QuickAlert) y redirigir a login.

---

## 1.9 Estructura de carpetas relevante (raíz lib/)

```
lib/
├── controller/          # Blocs y Controllers (AuthBloc, MonederoBloc, TransaccionesController, etc.)
├── data/                # Datasources, repository impl, modelos de data (cliente, extravio, transacciones)
├── domain/              # Repositories (abstract), entities, Result, use cases
├── model/               # Modelos compartidos (auth, monedero, transaccion, netpay, zonas, etc.)
├── services/            # Auth, Monedero, NetPay, Zonas, Rutas, Variantes, Monitoreo, Direccion, NFC, etc.
├── interceptors/        # SessionInterceptor (Dio)
├── view/                # Pantallas: dashboard, authentications, plugin (charts, maps, calendar), components
├── widgets/             # Rutas (app_routes, routes_name), scaffold_key, universal_dash, common
├── utils/               # date_formatter, location_helper, platform_detector, etc.
├── dashboardpro.dart    # Barrel file (exports)
└── main.dart            # Inicialización (Firebase, AuthBloc, carga de Google Maps JS en web, runApp)
```

---

## 1.10 Flujos de datos representativos

1. **Login:** UI → AuthBloc.login → AuthService.post('/login') → SecureStorage (token, user) → AuthBloc actualiza estado → GoRouter redirige.
2. **Monedero / transacciones general:** UI → MonederoBloc (obtenerWallet, obtenerTransacciones, etc.) → MonederoService (Dio + baseUrl) → API → respuesta parseada a modelos → streams actualizados.
3. **Viajes del día:** UI (Dashboard/Códigos QR/Estadísticas) → TransaccionesController.cargarViajesDelDia() → TransaccionesRepository → TransaccionesRemoteDataSource → MonederoService.obtenerListaTransacciones(token, page:1, limit:10, fechaInicio/Fin: hoy) → POST /transacciones/paginado → filtrado en UI (esDebito, lat/lng).
4. **Clientes públicos:** ClienteBloc / uso del repo → ClienteRepositoryImpl → ClienteRemoteDataSource.get('/clientes/public') → Result<List<ClienteEntity>>.
5. **Extravío:** ExtravioBloc → ExtravioRepository → ExtravioRemoteDataSource → API → Result<ExtravioReportResponse>.

---

## 1.11 Evolución reciente (27 de abril de 2026)

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

- **Google Maps (web):** `GOOGLE_MAPS_API_KEY` con `--dart-define` (p. ej. leyendo `google.maps.api.key` de `android/local.properties`).
- **NetPay:** la llave pública de cliente para tokenización se mantiene en el código de servicio NetPay y documentos asociados; actualizar de forma coordinada con backend/NetPay.

---

Este documento describe el contexto de **toda** la solución; los contratos detallados por capa y módulo se encuentran en `02_CONTRATOS_SOLUCION.md`.
