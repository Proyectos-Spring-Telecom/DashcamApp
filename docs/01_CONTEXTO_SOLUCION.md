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
| **Web** | Google Maps JS inyectado desde `main.dart` con `--dart-define=GOOGLE_MAPS_API_KEY`. |

**Dependencias principales:** Flutter SDK ≥3.4.1, Dio (HTTP), go_router, flutter_secure_storage, Firebase (core, Firestore), google_maps_flutter, Syncfusion (charts, maps, PDF, etc.), quickalert, mobile_scanner, qr_flutter, geolocator, NFC (flutter_nfc_kit), entre otras.

---

## 1.3 Arquitectura de capas

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

## 1.4 Módulos y funcionalidades principales

| Módulo | Descripción | Servicios / Blocs principales |
|--------|-------------|-----------------------------|
| **Autenticación** | Login, registro, verificación de correo, recuperación de contraseña, cambio de contraseña, foto de perfil | AuthService, AuthBloc, SecureStorageService |
| **Monedero** | Wallet del pasajero, monederos activos, recargas, transacciones paginadas, lista de clientes/pasajeros/tipos pasajero, creación de monederos | MonederoService, MonederoBloc |
| **Transacciones / Viajes del día** | Listado de transacciones del día (POST /transacciones/paginado), filtro por tipo DEBITO y ubicación (lat/lng), Último viaje y Actividad en Dashboard, Códigos QR y Estadísticas | MonederoService (reutilizado), TransaccionesRemoteDataSource, TransaccionesRepository, TransaccionesController |
| **Transacciones débito QR** | Transacciones débito QR del día (endpoint específico paginado) | TransaccionQrDebitoService, TransaccionQrDebitoBloc |
| **NetPay** | Tokenización de tarjetas, cliente NetPay, WebView para pago, asignación de tarjetas | NetPayService, NetPayTokenizationService, NetPayWebviewService, NetPayBloc, NetPayTokenizationBloc |
| **Transporte** | Zonas, rutas, variantes, monitoreo de unidades, direcciones por CP, mapa con geocercas y polylines | ZonasService, RutasService, VariantesService, MonitoreoService, DireccionService; ZonasBloc, RutasBloc, VariantesBloc, MonitoreoBloc, DireccionBloc |
| **Clientes (público)** | Listado de clientes activos sin autenticación | ClienteRemoteDataSource, ClienteRepository, ClienteRepositoryImpl |
| **Extravío** | Reporte de extravío | ExtravioRemoteDataSource, ExtravioRepository, ExtravioRepositoryImpl, ExtravioBloc |
| **Tema** | Modo claro/oscuro según sistema o preferencia | ThemeBloc |
| **NFC / plataforma** | NFC (stub en web), detección de plataforma, helpers de dispositivo | NfcService, platform_detector, device_info_helper |

---

## 1.5 API backend

- **Base URL:** `https://dashcampay.com/apidev`
- **Autenticación:** Bearer token en header `Authorization` para la mayoría de los endpoints.
- **Endpoints públicos (sin token):** login, register, forgot-password, resend-code, verify-code, `clientes/public`.
- **Interceptor:** `SessionInterceptor` (Dio) detecta respuestas que indican sesión inválida y delega en `SessionManager` para cerrar sesión (por ejemplo redirección a login).

---

## 1.6 Navegación y roles

- **Navegación:** GoRouter (`lib/widgets/routes/app_routes.dart`); rutas definidas en `RoutesName`.
- **Ruta inicial:** según si el usuario está logueado y su rol: no logueado → bienvenida; logueado y rol **Cajero** → POS; resto → Dashboard.
- **Rutas protegidas:** si no hay sesión, se redirige a login. Si hay sesión y se accede a login/register/bienvenida, se redirige a la ruta inicial según rol.
- **Rutas principales:** `/` (init), `/bienvenida`, `/login`, `/dashboard`, `/pos`, `/codigos-qr`, `/transacciones`, `/transporte`, `/ingresar-monto`, `/monederos`, `/perfil`, `/metodos-pago`, `/transporte`, `/googleMaps`, entre otras.

---

## 1.7 Seguridad y persistencia

- **Token y usuario:** persistidos con `SecureStorageService` (flutter_secure_storage); el token se envía en las peticiones que no son públicas.
- **Expiración de sesión:** manejada por `SessionManager` y `SessionInterceptor`; la UI puede mostrar alertas (p. ej. QuickAlert) y redirigir a login.

---

## 1.8 Estructura de carpetas relevante (raíz lib/)

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
└── main.dart            # Inicialización (Google Maps web opcional, Firebase, AuthBloc, runApp)
```

---

## 1.9 Flujos de datos representativos

1. **Login:** UI → AuthBloc.login → AuthService.post('/login') → SecureStorage (token, user) → AuthBloc actualiza estado → GoRouter redirige.
2. **Monedero / transacciones general:** UI → MonederoBloc (obtenerWallet, obtenerTransacciones, etc.) → MonederoService (Dio + baseUrl) → API → respuesta parseada a modelos → streams actualizados.
3. **Viajes del día:** UI (Dashboard/Códigos QR/Estadísticas) → TransaccionesController.cargarViajesDelDia() → TransaccionesRepository → TransaccionesRemoteDataSource → MonederoService.obtenerListaTransacciones(token, page:1, limit:10, fechaInicio/Fin: hoy) → POST /transacciones/paginado → filtrado en UI (esDebito, lat/lng).
4. **Clientes públicos:** ClienteBloc / uso del repo → ClienteRepositoryImpl → ClienteRemoteDataSource.get('/clientes/public') → Result<List<ClienteEntity>>.
5. **Extravío:** ExtravioBloc → ExtravioRepository → ExtravioRemoteDataSource → API → Result<ExtravioReportResponse>.

Este documento describe el contexto de **toda** la solución; los contratos detallados por capa y módulo se encuentran en `02_CONTRATOS_SOLUCION.md`.
