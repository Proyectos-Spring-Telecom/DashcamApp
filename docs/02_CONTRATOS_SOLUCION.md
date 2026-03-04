# 2. Contratos de la solución

Contratos por capa y módulo para toda la aplicación (API, dominio, datos, servicios, presentación).

---

## 2.1 Convenciones generales

- **Base URL API:** `https://dashcampay.com/apidev`
- **Autenticación:** `Authorization: Bearer {token}` salvo en endpoints públicos.
- **Headers habituales:** `Content-Type: application/json`, `Accept: application/json`
- **Manejo de errores:** los servicios suelen lanzar excepciones propias (AuthException, MonederoException, etc.); los repositorios que siguen el patrón Result devuelven `Result.failure(message, statusCode)`.

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

- Reporte de extravío; baseUrl: dashcampay.com/apidev.
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

### Auth (AuthService)

| Método HTTP | Ruta | Uso |
|-------------|------|-----|
| POST | /login | login(userName, password) |
| POST | /register | registro |
| POST | /verify-code | verificación de correo |
| POST | /forgot-password | recuperación de contraseña |
| POST | /resend-code | reenvío de código |
| POST | /change-password | cambio de contraseña |
| POST | (upload) | foto de perfil |

Todos con body JSON según modelo (LoginResponse, RegistroResponse, etc.).

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

- Endpoints propios de NetPay (tokenización, cliente, asignación de tarjetas, etc.); no detallados aquí.

---

## 2.7 Contrato del interceptor de sesión

**Archivo:** `lib/interceptors/session_interceptor.dart`

- **Tipo:** Dio `Interceptor`.
- **Endpoints públicos (no requieren token):** `/login`, `/register`, `/forgot-password`, `/resend-code`, `/verify-code`, `/clientes/public`.
- **Comportamiento en error:** si la respuesta indica sesión inválida (`SessionManager.isSessionInvalid(responseData, statusCode)`), rechaza la petición con error "Sesión expirada" y llama a `SessionManager.handleSessionExpired()` para cerrar sesión en la app.

---

## 2.8 Contratos de servicios (resumen)

| Servicio | Responsabilidad | Cliente HTTP |
|----------|-----------------|--------------|
| AuthService | Login, registro, verify, forgot/resend/change password, foto perfil | Dio (baseUrl apidev) + SessionInterceptor |
| SecureStorageService | Guardar/obtener token y usuario (flutter_secure_storage) | — |
| MonederoService | Monederos, wallet, transacciones paginadas, recargas, clientes/pasajeros/catpasajero, QR saldo, crear monedero | Dio (baseUrl apidev) + SessionInterceptor |
| TransaccionQrDebitoService | Transacciones débito QR paginadas | Dio |
| ZonasService | Zonas | Dio (baseUrl apidev) |
| RutasService | Rutas | Dio (baseUrl apidev) |
| VariantesService | Variantes | Dio (baseUrl apidev) |
| MonitoreoService | Monitoreo | Dio (baseUrl apidev) |
| DireccionService | Consulta por CP | Dio (baseUrl apidev) |
| NetPayService / NetPayTokenizationService / NetPayWebviewService | NetPay | Dio / WebView según flujo |

Todos los que usan Dio contra apidev pueden compartir la misma baseUrl y, donde aplique, el mismo interceptor de sesión.

---

## 2.9 Contratos de presentación (Blocs / Controllers)

### AuthBloc

**Archivo:** `lib/controller/auth_bloc.dart`

- **Estado:** AuthStatus (unauthenticated, authenticated, loading, error), User? currentUser, String? currentToken.
- **Streams:** authStatusStream, userStream, errorStream.
- **Métodos principales:** initialize(), login(userName, password), logout(), register, verifyEmail, changePassword, etc.
- **Dependencias:** AuthService, SecureStorageService.

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

- **Auth:** User, LoginResponse, RegistroRequest/Response, VerifyRequest/Response, ForgotPasswordRequest/Response, ChangePasswordRequest/Response, ResendCodeRequest/Response, FotoPerfilResponse, Rol, Permiso.
- **Monedero:** MonederoModel, MonederoRequest/Response, PasajeroWalletModel, QrWalletModel, ClienteModel, PasajeroModel, TipoPasajeroModel, MonederosPaginadosResponse, etc.
- **Transacciones:** TransaccionModel, TransaccionesResponse, PaginacionModel, TransaccionRequest/Response, RecargaRequest.
- **NetPay:** CardTokenRequest/Response, NetPayCustomerModel, AssignCardTokenRequest, CreateCustomerRequest/Response, etc.
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

## 2.12 Resumen de contratos por capa

| Capa | Contratos principales |
|------|------------------------|
| **Dominio** | Result&lt;T&gt;, ClienteRepository, ExtravioRepository, TransaccionesRepository; entidades (ClienteEntity, ExtravioReportRequest/Response). |
| **Data** | ClienteRemoteDataSource, ExtravioRemoteDataSource, TransaccionesRemoteDataSource; ClienteRepositoryImpl, ExtravioRepositoryImpl, TransaccionesRepositoryImpl; modelos de data (ClienteModel, etc.). |
| **Servicios** | AuthService, MonederoService, TransaccionQrDebitoService, ZonasService, RutasService, VariantesService, MonitoreoService, DireccionService, NetPay*, SecureStorageService; baseUrl apidev; excepciones propias por servicio. |
| **Infraestructura** | SessionInterceptor (Dio), SessionManager (expiración de sesión). |
| **Presentación** | AuthBloc, MonederoBloc, TransaccionesController, ThemeBloc, TransaccionQrDebitoBloc, ZonasBloc, RutasBloc, VariantesBloc, MonitoreoBloc, DireccionBloc, NetPayBloc, ExtravioBloc, ClienteBloc; GoRouter y RoutesName. |
| **API** | POST/GET contra https://dashcampay.com/apidev; autenticación Bearer salvo endpoints públicos; estructura de request/response según cada endpoint (login, transacciones/paginado, clientes/public, etc.). |

Este documento describe los contratos de **toda** la solución; para detalles de request/response de un endpoint concreto, consultar el servicio o datasource correspondiente en el código.
