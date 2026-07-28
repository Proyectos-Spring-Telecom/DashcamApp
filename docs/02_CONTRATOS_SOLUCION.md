# 2. Contratos de la solución

Contratos por capa y módulo para toda la aplicación (API, dominio, datos, servicios, presentación).

---

## 2.1 Convenciones generales

- **Base URL API:** `EnvConfig.apiBaseUrl` — por defecto `https://dashcampay.com/apidev` (Dev). Producción: `https://dashcampay.com/api` vía `.env.production` / `--dart-define`.
- **Base URL auth:** `EnvConfig.authApiBaseUrl` — igual a `apiBaseUrl` salvo que se defina `AUTH_API_BASE_URL`.
- **Desarrollo Web (localhost):** en debug, `EnvConfig` redirige a `http://127.0.0.1:8090/apidev` (proxy CORS). Flag `EnvConfig.usesWebDevProxy`.
- **Autenticación:** `Authorization: Bearer {token}` salvo en endpoints públicos.
- **Headers habituales:** `Content-Type: application/json`, `Accept: application/json`
- **Manejo de errores:** los servicios suelen lanzar excepciones propias (AuthException, MonederoException, etc.); los repositorios que siguen el patrón Result devuelven `Result.failure(message, statusCode)`.
- **HTTP 429:** manejado globalmente por `RateLimitInterceptor` (alerta QuickAlert + reject con extra `rate_limit_handled`).

---

## 2.2 Contrato del dominio compartido

### Result&lt;T&gt;

**Archivo:** `lib/domain/entities/result.dart`

| Miembro | Tipo | Descripción |
|--------|------|-------------|
| `isSuccess` | bool | true si la operación fue exitosa. |
| `data` | T? | Datos cuando isSuccess es true. |
| `errorMessage` | String? | Mensaje de error cuando isSuccess es false. |
| `statusCode` | int? | Código HTTP opcional. |

**Constructores:** `Result.success(T data, {int? statusCode})`, `Result.failure(String message, {int? statusCode})`.

---

## 2.2.1 Contrato de configuración (EnvConfig)

**Archivo:** `lib/core/env_config.dart`

| Propiedad / getter | Descripción |
|--------------------|-------------|
| `configuredApiBaseUrl` | URL configurada sin proxy (p. ej. `https://dashcampay.com/apidev` o `/api`). |
| `apiBaseUrl` | URL efectiva para servicios; en Web localhost debug → proxy local. |
| `authApiBaseUrl` | Base para auth; usa `AUTH_API_BASE_URL` si existe, si no `apiBaseUrl`. |
| `googleMapsApiKey` | Clave Maps (`--dart-define` o `.env`). |
| `netpayPublicApiKey` | Llave pública NetPay `pk_*` (nunca `sk_*` en cliente). |
| `appEnv` | Ambiente: `development`, `qa`, `production`. |
| `usesWebDevProxy` | `true` si Web + debug + localhost y proxy habilitado. |
| `webDevProxyUrl` | `http://127.0.0.1:8090/apidev` (puerto configurable con `WEB_DEV_PROXY_PORT`). |

**Prioridad de resolución:** `--dart-define` > `flutter_dotenv` (`.env`) > valor por defecto.

**Proxy de desarrollo Web:** `tool/dev_api_proxy.dart` — reenvía a la API real e inyecta cabeceras CORS. Solo necesario en Flutter Web sobre `localhost`.

---

## 2.3 Contratos de repositorios (dominio)

### ClienteRepository

**Archivo:** `lib/domain/repositories/cliente_repository.dart`

```dart
abstract class ClienteRepository {
  Future<Result<List<ClienteEntity>>> obtenerClientesPublicos();
}
```

- Sin autenticación; endpoint público.

### ExtravioRepository

**Archivo:** `lib/domain/repositories/extravio_repository.dart`

```dart
abstract class ExtravioRepository {
  Future<Result<ExtravioReportResponse>> reportarExtravio(
    ExtravioReportRequest request,
    String? token,
  );
}
```

### TransaccionesRepository

**Archivo:** `lib/domain/repositories/transacciones_repository.dart`

```dart
abstract class TransaccionesRepository {
  Future<Result<List<TransaccionModel>>> obtenerViajesDelDia();
}
```

- Usado por el flujo “viajes del día” (Dashboard, Códigos QR, Estadísticas).

---

## 2.4 Contratos de datasources (data)

### ClienteRemoteDataSource

**Archivo:** `lib/data/datasources/cliente_remote_datasource.dart`

- **Método:** `Future<List<ClienteModel>> obtenerClientesPublicos()`
- **HTTP:** GET `/clientes/public`
- **Excepción:** `ClienteException(message, statusCode)`

### ExtravioRemoteDataSource

**Archivo:** `lib/data/datasources/extravio_remote_datasource.dart`

- Reporte de extravío; baseUrl: `EnvConfig.apiBaseUrl`.
- **Excepción:** tipo específico de extravío (según implementación).

### TransaccionesRemoteDataSource

**Archivo:** `lib/data/datasources/transacciones_remote_datasource.dart`

- **Dependencias:** MonederoService, AuthBloc
- **Método:** `Future<List<TransaccionModel>> obtenerTransaccionesHoy()`
- **Implementación:** llama a MonederoService.obtenerListaTransacciones(token, page: 1, limit: 10, fechaInicio/fin: hoy).
- **Excepción:** `TransaccionesException(message, statusCode)` (sin token, MonederoException o error genérico).

---

## 2.5 Contratos de implementaciones de repositorios (data)

### ClienteRepositoryImpl

- Implementa `ClienteRepository`; depende de `ClienteRemoteDataSource`.
- Convierte modelos a entidades y devuelve `Result.success` o `Result.failure` según `ClienteException`.

### ExtravioRepositoryImpl

- Implementa `ExtravioRepository`; depende del datasource de extravío.
- Devuelve `Result<ExtravioReportResponse>`.

### TransaccionesRepositoryImpl

- Implementa `TransaccionesRepository`; depende de `TransaccionesRemoteDataSource`.
- `obtenerViajesDelDia()` → delega en datasource; captura `TransaccionesException` y devuelve `Result.failure`.

---

## 2.6 Contratos del API (endpoints principales)

Los servicios usan Dio contra la base URL indicada. Resumen por servicio:

### Auth (AuthService + AuthApiService)

**AuthApiService** (`lib/services/auth_api_service.dart`): cliente Dio **sin** `SessionInterceptor` (evita ciclos en refresh). Incluye `RateLimitInterceptor`.

| Método HTTP | Ruta | Uso | Respuesta |
|-------------|------|-----|-----------|
| POST | /login | login(userName, password) | `{ token, refreshToken }` → `LoginResponse` |
| POST | /login/refresh | refreshTokens(refreshToken) | `{ token, refreshToken }` → `LoginResponse` |

**AuthService** (`lib/services/auth_service.dart`): resto de operaciones auth y perfil.

| Método HTTP | Ruta | Uso | Autenticación |
|-------------|------|-----|---------------|
| GET | /login/me | fetchCurrentUser(token) — perfil completo (rol, permisos, cliente) | Bearer |
| POST | /register | registro | No |
| POST | /verify-code | verificación de correo (**código 6 dígitos**) | No |
| POST | /forgot-password | recuperación de contraseña | No |
| POST | /resend-code | reenvío de código | No |
| PUT | /usuarios/actualizar/contrasena | cambio de contraseña (body: passwordActual, passwordNueva, passwordNuevaConfirmacion; sin id en ruta) | Sí |
| POST | (upload) | foto de perfil | Sí |

**LoginResponse** (`lib/model/auth/login_response.dart`):

```dart
class LoginResponse {
  final String token;
  final String refreshToken;
  // fromJson: token, refreshToken
}
```

**Flujo post-login:** `AuthBloc.applyRefreshedTokens()` → guarda tokens → `GET /login/me` → persiste `User` (fallback `User.fromAccessToken` si `/login/me` falla).

### Monedero (MonederoService)

| Método HTTP | Ruta / uso | Autenticación |
|-------------|------------|----------------|
| GET | /monederos/paginados/activos?page=&limit= | Sí |
| GET | /pasajeros/wallet?anio= | Sí |
| POST | /transacciones/recarga | Sí |
| POST | /transacciones/paginado | Sí (body: page, limit, fechaInicio, fechaFin) |
| POST | /monederos/qr/saldo | Sí |
| GET | /clientes/list | Sí |
| GET | /pasajeros/list | Sí |
| GET | /catpasajero/list | Sí |
| POST | /monederos | Sí (crear monedero) |

### Transacciones débito QR (TransaccionQrDebitoService)

| Método HTTP | Ruta | Uso |
|-------------|------|-----|
| POST | /transacciones/paginado/debito-qr | Listado paginado débito QR del día |

### Clientes públicos

| Método HTTP | Ruta | Autenticación |
|-------------|------|----------------|
| GET | /clientes/public | No (público) |

### Zonas (ZonasService)

| Método HTTP | Ruta | Uso |
|-------------|------|-----|
| GET | (zonas) | Listado de zonas |

### Rutas (RutasService)

| Método HTTP | Ruta | Uso |
|-------------|------|-----|
| GET | (rutas) | Listado de rutas |

### Variantes (VariantesService)

| Método HTTP | Ruta | Uso |
|-------------|------|-----|
| GET | /variantes/list | Listado de variantes |

### Monitoreo (MonitoreoService)

| Método HTTP | Ruta | Uso |
|-------------|------|-----|
| GET | /monitoreo | Datos de monitoreo |

### Dirección (DireccionService)

| Método HTTP | Ruta | Uso |
|-------------|------|-----|
| GET | /direcciones/CP/{cp} | Consulta por código postal |

### NetPay (NetPayService, NetPayTokenizationService, NetPayWebviewService)

- Endpoints propios de NetPay (tokenización, cliente, asignación de tarjetas, etc.) según documentación NetPay.
- **Cliente (tokenización):** la llave pública (`pk_netpay_…`) se resuelve con `EnvConfig.netpayPublicApiKey`; el backend usa credenciales privadas para cargos y conciliación.
- **Recarga / monedero:** el parámetro que identifica la tarjeta guardada para cobrar debe ser el **token almacenado reutilizable** (`paymentSource.source` en la lista de medios de pago), no el `card.token` de un solo uso cuando aplique la documentación de NetPay.

---

## 2.7 Contratos de interceptores Dio

### SessionInterceptor

**Archivo:** `lib/interceptors/session_interceptor.dart`

- **Tipo:** Dio `Interceptor`.
- **Endpoints públicos (no requieren token):** `/login`, `/login/refresh`, `/register`, `/forgot-password`, `/resend-code`, `/verify-code`, `/clientes/public`.
- **HTTP 401:** delega primero a `RateLimitInterceptor.tryHandle`; si no es 429, intenta refresh vía `TokenRefreshService.refreshSession()` y reintenta la petición una vez (extra `retriedExtraKey`). Si el refresh falla o la respuesta indica sesión inválida → `SessionManager.handleSessionExpired()`.
- **HTTP 429:** delegado a `RateLimitInterceptor`.

### RateLimitInterceptor

**Archivo:** `lib/interceptors/rate_limit_interceptor.dart`

- **Tipo:** Dio `Interceptor` (también expone `tryHandle` estático para uso desde `SessionInterceptor`).
- **HTTP 429:** log debug `[HTTP 429] METHOD /path`, QuickAlert “Demasiados intentos” (una alerta a la vez), reject con extra `rate_limit_handled: true`.
- **Integración:** añadido en `AuthApiService`, `SessionInterceptor` (vía tryHandle), `ClienteRemoteDataSource`, `ExtravioRemoteDataSource`.

---

## 2.8 Contratos de servicios (resumen)

| Servicio | Responsabilidad | Cliente HTTP |
|----------|-----------------|--------------|
| AuthApiService | POST /login, POST /login/refresh (sin SessionInterceptor) | Dio + RateLimitInterceptor; baseUrl `EnvConfig.authApiBaseUrl` |
| AuthService | Registro, verify, forgot/resend/change password, GET /login/me, foto perfil | Dio (`EnvConfig.apiBaseUrl` / `authApiBaseUrl`) + SessionInterceptor |
| SecureStorageService | Guardar/obtener token, refresh token y usuario (flutter_secure_storage) | — |
| MonederoService | Monederos, wallet, transacciones paginadas, recargas, clientes/pasajeros/catpasajero, QR saldo, crear monedero | Dio (`EnvConfig.apiBaseUrl`) + SessionInterceptor |
| TransaccionQrDebitoService | Transacciones débito QR paginadas | Dio |
| ZonasService | Zonas | Dio (`EnvConfig.apiBaseUrl`) |
| RutasService | Rutas | Dio (`EnvConfig.apiBaseUrl`) |
| VariantesService | Variantes | Dio (`EnvConfig.apiBaseUrl`) |
| MonitoreoService | Monitoreo | Dio (`EnvConfig.apiBaseUrl`) |
| DireccionService | Consulta por CP | Dio (`EnvConfig.apiBaseUrl`) |
| NetPayService / NetPayTokenizationService / NetPayWebviewService | NetPay (API + tokenización); llave pública vía `EnvConfig.netpayPublicApiKey` | Dio; WebView en plataformas no web; **web:** `NetPayWebTokenizer` + NetPayJS |
| Implementación condicional `netpay_web_tokenizer_*` | Misma API Dart que WebView; en web ejecuta JS global `NetPay` | Solo Flutter Web |

Todos los que usan Dio comparten `EnvConfig.apiBaseUrl` y, donde aplique, interceptores de sesión y rate limit.

---

## 2.9 Contratos de presentación (Blocs / Controllers)

### AuthBloc

**Archivo:** `lib/controller/auth_bloc.dart`

- **Estado:** AuthStatus (unauthenticated, authenticated, loading, error), User? currentUser, String? currentToken.
- **Streams:** authStatusStream, userStream, errorStream.
- **Métodos principales:** initialize(), login(userName, password), logout(), register, verifyEmail, changePassword, applyRefreshedTokens(), refreshUserProfile(), refreshSession(), uploadProfilePhoto, etc.
- **Dependencias:** AuthService, AuthApiService (vía AuthService), SecureStorageService.
- **Post-login:** `applyRefreshedTokens` persiste token + refreshToken, llama `GET /login/me` y actualiza streams.

### MonederoBloc

**Archivo:** `lib/controller/monedero_bloc.dart`

- **Streams:** monederosStream, transaccionesStream, walletStream, qrStream, clientesStream, pasajerosStream, tiposPasajeroStream, etc., y sus correspondientes status/error streams.
- **Métodos:** obtenerMonederos(), obtenerTransacciones(), cargarMasTransacciones(), obtenerWallet(), obtenerClientes(), obtenerPasajeros(), obtenerTiposPasajero(), realizarCargo(), crearMonedero(), etc.
- **Dependencias:** MonederoService, AuthBloc.

### TransaccionesController

**Archivo:** `lib/controller/transacciones_controller.dart`

- **Tipo:** ChangeNotifier.
- **Estado:** ViajesDelDiaStatus (initial, loading, success, empty, error), List&lt;TransaccionModel&gt; viajes, String? errorMessage.
- **Métodos:** cargarViajesDelDia(), viajePorId(id).
- **Dependencias:** TransaccionesRepository (por defecto impl con TransaccionesRemoteDataSource + MonederoService + AuthBloc).
- **Instancia global:** `transaccionesController`.

### TransaccionQrDebitoBloc

- Streams de lista de transacciones débito QR y estado/error; carga paginada.
- Depende de TransaccionQrDebitoService y AuthBloc.

### ThemeBloc

- Tema claro/oscuro; streams y método para toggle/actualización.

### ZonasBloc, RutasBloc, VariantesBloc, MonitoreoBloc, DireccionBloc

- Exponen datos y estado de zonas, rutas, variantes, monitoreo y direcciones; consumen sus respectivos servicios y AuthBloc para el token.

### NetPayBloc, NetPayTokenizationBloc

- Gestionan estado de tokenización y flujos NetPay.

### ExtravioBloc, ClienteBloc

- Delegan en sus repositorios (ExtravioRepository, ClienteRepository) y exponen resultado/error.

---

## 2.10 Contratos de modelos compartidos (referencia)

- **Auth:** User, LoginResponse (`token`, `refreshToken`), RegistroRequest/Response, VerifyRequest/Response (código **6 dígitos**), ForgotPasswordRequest/Response, ChangePasswordRequest/Response, ResendCodeRequest/Response, FotoPerfilResponse, Rol, Permiso.
- **Monedero:** MonederoModel, MonederoRequest/Response, PasajeroWalletModel, QrWalletModel, ClienteModel, PasajeroModel, TipoPasajeroModel, MonederosPaginadosResponse, etc.
- **Transacciones:** TransaccionModel, TransaccionesResponse, PaginacionModel, TransaccionRequest/Response, RecargaRequest.
- **NetPay:** CardTokenRequest/Response (`saveCard` para vault/simpleUse), NetPayCustomerModel, AssignCardTokenRequest, CreateCustomerRequest/Response, modelos de `paymentSource` / tarjeta con distinción entre **source** (reutilizable) y **token** de sesión de tokenización.
- **Transporte / Zonas:** ZonaModel, ZonasResponse; modelos de ruta, variante, estación, monitoreo (UnidadModel, PosicionModel), etc.
- **Dominio/Data:** ClienteEntity, ClienteModel; ExtravioReportRequest, ExtravioReportResponse; Result&lt;T&gt;.

Los modelos suelen exponer `fromJson` / `toJson` y getters de negocio (por ejemplo TransaccionModel.esDebito, nombrePasajeroCompleto).

---

## 2.11 Contrato de navegación (GoRouter)

**Archivo:** `lib/widgets/routes/app_routes.dart`, `lib/widgets/routes/routes_name.dart`

- **Redirect:** si no logueado y ruta no pública → login; si logueado y ruta de auth → ruta inicial según rol (Cajero → POS, resto → Dashboard).
- **Rutas:** definidas en `RoutesName` (init, bienvenida, login, register, dashboard, pos, codigosQR, transacciones, transporte, ingresarMonto, monederos, perfil, metodosPago, cambioContrasena, googleMaps, etc.).
- **Claves de scaffold:** `ScaffoldKey` para algunas pantallas (dashboard, pos, etc.).

---

## 2.12 Contrato de build y dependencias de plataforma

### Web

- **Comando de build:** `flutter build web --release --base-href /dashcampay/ --dart-define=GOOGLE_MAPS_API_KEY=<clave> --dart-define-from-file=.env`.
- **Desarrollo local:** proxy CORS en terminal separada (`dart run tool/dev_api_proxy.dart`) o `scripts/run_web_dev.sh`. La app en localhost usa automáticamente el proxy en debug.
- **Variable de entorno / clave:** `.env` (gitignored) o `--dart-define`; Maps también desde `android/local.properties` (`google.maps.api.key`).
- **Opcional:** `--no-wasm-dry-run` para omitir avisos de incompatibilidad Wasm (p. ej. flutter_secure_storage_web).

### Android

- **Kotlin Gradle plugin:** versión **2.3.0** en `android/settings.gradle` (bloque `plugins`, `id "org.jetbrains.kotlin.android"`). Requerido para compatibilidad con dependencias que usan metadata Kotlin 2.3.x (p. ej. kotlin-stdlib 2.3.10).
- **Google Maps:** clave en `android/local.properties` como `google.maps.api.key=...`; se inyecta vía `manifestPlaceholders` en `app/build.gradle`.

### number_pagination (DataTables / pagination_datagrid)

- **Versión en uso:** 1.1.6 (pubspec: `number_pagination: ^1.0.6`).
- **Widget:** `NumberPagination`. Parámetros de la API actual (no usar nombres antiguos):
  - **Requeridos:** `onPageChanged`, `totalPages`, `currentPage`.
  - **Opcionales:** `visiblePagesCount` (default 10), `fontSize`, y el resto según documentación del paquete.
- **Nombres obsoletos (no existen en 1.1.6):** `pageTotal`, `pageInit`, `threshold`, `controlButton`; sustituir por `totalPages`, `currentPage`, `visiblePagesCount` y eliminar `controlButton`.

---

## 2.13 Contrato de presentación: Movilidad Inteligente (mapa)

**Archivo principal:** `lib/view/dashboard/transporte.dart`  
**Dependencias:** paquetes `google_maps_flutter` y `geolocator`; blocs de zonas, rutas, variantes y monitoreo.

| Aspecto | Contrato / comportamiento |
|---------|---------------------------|
| Origen del centro del mapa | Solo coordenadas de **ubicación actual** (Geolocator). Sin segunda “posición inicial” de producto; un único `LatLng? _currentLocation`. |
| Antes de tener GPS | Estado de carga: `_isLoadingLocation == true` y UI “Obteniendo tu ubicación…”. No se instancia `GoogleMap` hasta resolver ubicación (o fallback de error). |
| Fallback sin GPS | Constante interna de respaldo (último recurso) solo si servicio/permisos fallan; no sustituye el flujo normal de GPS. |
| Zoom | `_zoomContextoInicial` (~15) al abrir; `_zoomCercaMarkerUsuario` (~17,35) tras mostrar markers del usuario (animación con breve retardo). |
| Overlay “Cargando mapa…” | Visible solo si `onMapCreated` supera un **debounce** (~350 ms móvil / ~450 ms web); el debounce del mapa se programa tras fijar `_currentLocation`. |
| `GoogleMapController` | No llamar a `dispose()` en el `State`; poner referencia a `null` en `dispose` del widget si se requiere. |
| Web | La clave `GOOGLE_MAPS_API_KEY` debe coincidir con restricciones y APIs habilitadas en Google Cloud (p. ej. Maps JavaScript API). |

---

## 2.14 Contrato de integración cliente: NetPay (tokenización y recarga)

**Archivos de referencia:** `lib/services/netpay_webview_service.dart`, `lib/services/netpay_web_tokenizer_web.dart` (web) / stub, `lib/services/netpay_service.dart`, `assets/html/netpay_tokenization.html`, `web/index.html`.

| Tema | Contrato |
|------|----------|
| Plataformas | **Web:** `kIsWeb` → `NetPayWebTokenizer` (NetPayJS en DOM). **No web:** `WebView` + HTML embebido. No inicializar `WebView` en web. |
| `CardTokenRequest` | Incluye `saveCard` (p. ej. `true` para guardar en vault). Debe mapearse a `vault` / `simpleUse` en JS según documentación NetPay. |
| Selección de tarjeta guardada | La UI de recarga debe identificar el medio con **`paymentSource.source`** (token reutilizable de cargo), no confundir con `card.token` de operación de un solo uso. |
| Resumen de recarga (`resumen.dart`) | `tokenCardNetPay` prioriza `source` sobre `card.token` si `source` no está vacío. |
| Errores de red (web) | Mensajes al usuario vía `QuickAlert` informativo en el flujo de nueva tarjeta cuando aplique; sin duplicar error crítico en recuadro rojo inline en esos casos. |
| Documentación externa | Comportamiento alineado con [documentación NetPay](https://docs.netpay.com.mx) (my-requests, tokenización, cobros). |

---

## 2.16 Contrato de presentación: autenticación (registro, verificación, contraseña)

### PasswordRules / PasswordSecurityMeter

**Archivos:** `lib/utils/password_rules.dart`, `lib/widgets/password_security_meter.dart`

| Regla | Valor |
|-------|-------|
| Longitud | 12–16 caracteres |
| Minúscula | al menos una `[a-z]` |
| Número | al menos un dígito |
| Símbolo | al menos uno de `[!@#$%^&*(),.?":{}|<>]` |
| Espacios | no permitidos |

**Uso:** `register.dart`, `cambio_contrasena.dart` — widget `PasswordSecurityMeter` muestra semáforo visual de cumplimiento.

### Verificación de correo (email_verify.dart)

| Aspecto | Contrato |
|---------|----------|
| Longitud del código | **6 dígitos** (`_verificationCodeLength = 6`) |
| Entrada | campos numéricos individuales; solo dígitos |
| Hot reload | `_initCodeFields()`, `_ensureCodeFields()`, `reassemble()` para evitar desincronización de listas |

### Registro — fecha de nacimiento (CalendarDatePicker2)

**Archivo:** `lib/view/extras/authentications/register.dart` — método `_abrirDialogFechaNacimiento`.

| Aspecto | Contrato |
|---------|----------|
| Paquete | `calendar_date_picker2` ^2.0.1 |
| Diálogo | `showCalendarDatePicker2Dialog` |
| Ancho responsive | `(screenWidth - 32).clamp(240, 400)` |
| Modo compacto (`dialogWidth < 320`) | `disableMonthPicker: true` (selector único "Mes Año"), `useAbbrLabelForMonthModePicker`, `modePickersGap: 0`, tipografías reducidas |
| Meses | español completo en pantallas amplias; abreviados (`Ene`, `Feb`, …) en compacto |
| Rango de fechas | `firstDate`: hoy − 120 años; `lastDate`: hoy |

---

## 2.17 Resumen de contratos por capa

| Capa | Contratos principales |
|------|------------------------|
| **Configuración** | EnvConfig (apiBaseUrl, authApiBaseUrl, claves, proxy Web); `.env` + `--dart-define-from-file`. |
| **Dominio** | Result&lt;T&gt;, ClienteRepository, ExtravioRepository, TransaccionesRepository; entidades (ClienteEntity, ExtravioReportRequest/Response). |
| **Data** | ClienteRemoteDataSource, ExtravioRemoteDataSource, TransaccionesRemoteDataSource; ClienteRepositoryImpl, ExtravioRepositoryImpl, TransaccionesRepositoryImpl; modelos de data (ClienteModel, etc.). |
| **Servicios** | AuthApiService, AuthService, MonederoService, TransaccionQrDebitoService, ZonasService, RutasService, VariantesService, MonitoreoService, DireccionService, NetPay*, SecureStorageService; baseUrl vía EnvConfig; excepciones propias por servicio. |
| **Infraestructura** | SessionInterceptor (refresh 401, expiración), RateLimitInterceptor (429), SessionManager, TokenRefreshService; proxy dev Web (`tool/dev_api_proxy.dart`). |
| **Presentación** | AuthBloc, MonederoBloc, TransaccionesController, ThemeBloc, TransaccionQrDebitoBloc, ZonasBloc, RutasBloc, VariantesBloc, MonitoreoBloc, DireccionBloc, NetPayBloc, ExtravioBloc, ClienteBloc; PasswordSecurityMeter; GoRouter y RoutesName. |
| **Build / plataforma** | Web: base-href /dashcampay/, GOOGLE_MAPS_API_KEY, `--dart-define-from-file=.env`, proxy CORS en dev. Android: Kotlin 2.3.0; google.maps.api.key; sin Firebase. number_pagination 1.1.6. |
| **Autenticación (UI)** | Ver §2.16: PasswordRules, verificación 6 dígitos, CalendarDatePicker2 responsive. |
| **Movilidad Inteligente (mapa)** | Ver §2.13: ubicación actual obligatoria para instanciar mapa, zoom en dos fases, debounce de overlay, sin `dispose` manual del controlador. |
| **NetPay (cliente)** | Ver §2.14: tokenización web vs WebView, `saveCard` / vault, recarga con `paymentSource.source`, llave vía EnvConfig. |
| **API** | POST/GET contra `EnvConfig.apiBaseUrl` (`apidev` / `api`); auth: /login, /login/refresh, /login/me; Bearer salvo endpoints públicos. |

Este documento describe los contratos de **toda** la solución; para detalles de request/response de un endpoint concreto, consultar el servicio o datasource correspondiente en el código. **Actualización:** 28 de julio de 2026 (ambientes Dev `apidev` / Prod `api`, cambio de contraseña sin id en ruta).
