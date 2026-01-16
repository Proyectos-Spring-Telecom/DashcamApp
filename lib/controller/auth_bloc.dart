import 'dart:async';
import 'package:dashboardpro/model/auth/user.dart';
import 'package:dashboardpro/model/auth/registro_request.dart';
import 'package:dashboardpro/model/auth/registro_response.dart';
import 'package:dashboardpro/model/auth/verify_request.dart';
import 'package:dashboardpro/model/auth/verify_response.dart';
import 'package:dashboardpro/model/auth/forgot_password_request.dart';
import 'package:dashboardpro/model/auth/forgot_password_response.dart';
import 'package:dashboardpro/model/auth/resend_code_request.dart';
import 'package:dashboardpro/model/auth/resend_code_response.dart';
import 'package:dashboardpro/model/auth/change_password_request.dart';
import 'package:dashboardpro/model/auth/change_password_response.dart';
import 'package:dashboardpro/model/auth/foto_perfil_response.dart';
import 'package:dashboardpro/services/auth_service.dart';
import 'package:dashboardpro/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
// Imports condicionales para File
import 'dart:io' if (dart.library.html) 'package:dashboardpro/services/auth_service_file_stub.dart';

enum AuthStatus {
  unauthenticated,
  authenticated,
  loading,
  error,
}

class AuthBloc {
  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();

  final _authController = StreamController<AuthStatus>.broadcast();
  final _userController = StreamController<User?>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  Stream<AuthStatus> get authStatusStream => _authController.stream;
  Stream<User?> get userStream => _userController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  AuthStatus _authStatus = AuthStatus.unauthenticated;
  User? _currentUser;
  String? _currentToken;

  AuthStatus get authStatus => _authStatus;
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;

  AuthBloc();

  /// Inicializa el estado de autenticación al iniciar la app
  Future<void> initialize() async {
    try {
      final token = await _storageService.getToken();
      final user = await _storageService.getUser();

      if (token != null && token.isNotEmpty && user != null) {
        _currentToken = token;
        _currentUser = user;
        _authStatus = AuthStatus.authenticated;
        _authController.add(_authStatus);
        _userController.add(_currentUser);
      } else {
        _authStatus = AuthStatus.unauthenticated;
        _authController.add(_authStatus);
        _userController.add(null);
      }
    } catch (e) {
      debugPrint('Error al inicializar autenticación: $e');
      _authStatus = AuthStatus.unauthenticated;
      _authController.add(_authStatus);
      _userController.add(null);
    }
  }

  /// Realiza el login del usuario
  Future<bool> login(String userName, String password) async {
    try {
      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      final loginResponse = await _authService.login(userName, password);

      // Guardar token y usuario
      await _storageService.saveToken(loginResponse.token);
      final user = User.fromLoginResponse(loginResponse);
      await _storageService.saveUser(user);

      // Actualizar estado
      _currentToken = loginResponse.token;
      _currentUser = user;
      _authStatus = AuthStatus.authenticated;

      _authController.add(_authStatus);
      _userController.add(_currentUser);
      _errorController.add(null);

      return true;
    } on AuthException catch (e) {
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add(e.message);
      _userController.add(null);
      return false;
    } catch (e) {
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      _userController.add(null);
      return false;
    }
  }

  /// Registra un nuevo pasajero
  Future<RegistroResponse?> registerPasajero({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String fechaNacimiento,
    required String correo,
    required String passwordHash,
    String? numeroSerieMonedero,
    required String telefono,
  }) async {
    try {
      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      final request = RegistroRequest(
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        fechaNacimiento: fechaNacimiento,
        correo: correo,
        passwordHash: passwordHash,
        numeroSerieMonedero: numeroSerieMonedero,
        telefono: telefono,
      );

      final registroResponse = await _authService.registerPasajero(request);

      // Limpiar estado de error
      _authStatus = AuthStatus.unauthenticated;
      _authController.add(_authStatus);
      _errorController.add(null);

      return registroResponse;
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en registerPasajero: ${e.message}');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add(e.message);
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en registerPasajero: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      return null;
    }
  }

  /// Verifica el código de verificación de email
  Future<VerifyResponse?> verifyEmail({
    required String userName,
    required String code,
  }) async {
    try {
      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      // El servicio solo requiere el código, no el userName
      final request = VerifyRequest(
        codigo: code,
      );

      final verifyResponse = await _authService.verifyEmail(request);

      // Limpiar estado de error
      _authStatus = AuthStatus.unauthenticated;
      _authController.add(_authStatus);
      _errorController.add(null);

      return verifyResponse;
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en verifyEmail: ${e.message}');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add(e.message);
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en verifyEmail: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      return null;
    }
  }

  /// Recupera la contraseña enviando un código al correo electrónico
  Future<ForgotPasswordResponse?> recoverPassword({
    required String userName,
  }) async {
    try {
      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      final request = ForgotPasswordRequest(
        userName: userName,
      );

      final recoverResponse = await _authService.recoverPassword(request);

      // Limpiar estado de error
      _authStatus = AuthStatus.unauthenticated;
      _authController.add(_authStatus);
      _errorController.add(null);

      return recoverResponse;
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en recoverPassword: ${e.message}');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add(e.message);
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en recoverPassword: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      return null;
    }
  }

  /// Reenvía el código de verificación al correo electrónico del usuario
  Future<ResendCodeResponse?> resendCode({
    required String userName,
  }) async {
    try {
      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      final request = ResendCodeRequest(
        userName: userName,
      );

      final resendResponse = await _authService.resendCode(request);

      // Limpiar estado de error
      _authStatus = AuthStatus.unauthenticated;
      _authController.add(_authStatus);
      _errorController.add(null);

      return resendResponse;
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en resendCode: ${e.message}');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add(e.message);
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en resendCode: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      return null;
    }
  }

  /// Cambia la contraseña del usuario autenticado
  Future<ChangePasswordResponse?> changePassword({
    required String passwordActual,
    required String passwordNueva,
    required String passwordNuevaConfirmacion,
  }) async {
    try {
      // Validar que el usuario esté autenticado
      if (_currentUser == null) {
        throw AuthException('No hay un usuario autenticado. Por favor, inicia sesión nuevamente.');
      }

      // Validar que las contraseñas nuevas coincidan antes de enviar
      if (passwordNueva != passwordNuevaConfirmacion) {
        throw AuthException('Las contraseñas nuevas no coinciden.');
      }

      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      final request = ChangePasswordRequest(
        passwordActual: passwordActual,
        passwordNueva: passwordNueva,
        passwordNuevaConfirmacion: passwordNuevaConfirmacion,
      );

      final changePasswordResponse = await _authService.changePassword(
        userId: _currentUser!.id,
        request: request,
        token: _currentToken,
      );

      // Limpiar estado de error
      _authStatus = AuthStatus.authenticated;
      _authController.add(_authStatus);
      _errorController.add(null);

      return changePasswordResponse;
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en changePassword: ${e.message}');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add(e.message);
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en changePassword: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _authStatus = AuthStatus.error;
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      return null;
    }
  }

  /// Realiza el logout del usuario
  Future<void> logout() async {
    try {
      await _storageService.clearAll();
      _currentToken = null;
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;

      _authController.add(_authStatus);
      _userController.add(null);
      _errorController.add(null);
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      // Aun así, limpiar el estado local
      _currentToken = null;
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;
      _authController.add(_authStatus);
      _userController.add(null);
      // Agregar el error al controlador para mantener consistencia con otros métodos
      _errorController.add('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Actualiza la información del usuario en memoria
  void updateUser(User user) {
    _currentUser = user;
    _userController.add(_currentUser);
    // Guardar también en almacenamiento persistente
    _storageService.saveUser(user);
  }

  /// Sube o reemplaza la foto de perfil del usuario autenticado
  /// Retorna true si la operación fue exitosa, false si hubo error
  Future<bool> uploadProfilePhoto(File imageFile) async {
    try {
      // Validar que el usuario esté autenticado
      if (_currentUser == null) {
        throw AuthException('No hay un usuario autenticado. Por favor, inicia sesión nuevamente.');
      }

      if (_currentToken == null || _currentToken!.isEmpty) {
        throw AuthException('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      final fotoPerfilResponse = await _authService.uploadProfilePhoto(
        imageFile: imageFile,
        token: _currentToken,
      );

      // Si la respuesta indica éxito, actualizar el usuario
      // Nota: La respuesta puede incluir la URL de la foto actualizada,
      // pero si no la incluye, el usuario deberá recargar su perfil.
      // Por ahora, mantenemos el usuario actual y el cliente deberá refrescar la imagen.
      // Si el backend retorna la nueva URL, actualizaríamos aquí:
      
      _authStatus = AuthStatus.authenticated;
      _authController.add(_authStatus);
      _errorController.add(null);

      // Opcional: Si la respuesta incluye la URL de la foto, actualizar el usuario
      // Por ahora, solo marcamos como exitoso y dejamos que la UI refresque

      return true;
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en uploadProfilePhoto: ${e.message}');
      _authStatus = AuthStatus.authenticated; // Mantener autenticado aunque falle la subida
      _authController.add(_authStatus);
      _errorController.add(e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en uploadProfilePhoto: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _authStatus = AuthStatus.authenticated; // Mantener autenticado aunque falle la subida
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> uploadProfilePhotoWeb(Uint8List imageBytes) async {
    try {
      // Validar que el usuario esté autenticado
      if (_currentUser == null) {
        throw AuthException('No hay un usuario autenticado. Por favor, inicia sesión nuevamente.');
      }

      if (_currentToken == null || _currentToken!.isEmpty) {
        throw AuthException('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      _authStatus = AuthStatus.loading;
      _authController.add(_authStatus);
      _errorController.add(null);

      // En web, pasamos null para imageFile y los bytes directamente
      final fotoPerfilResponse = await _authService.uploadProfilePhoto(
        imageFile: null, // No se usa en web
        token: _currentToken,
        imageBytes: imageBytes,
      );

      // Si la respuesta indica éxito, actualizar el usuario
      // Nota: La respuesta puede incluir la URL de la foto actualizada,
      // pero si no la incluye, el usuario deberá recargar su perfil.
      // Por ahora, mantenemos el usuario actual y el cliente deberá refrescar la imagen.
      // Si el backend retorna la nueva URL, actualizaríamos aquí:
      
      _authStatus = AuthStatus.authenticated;
      _authController.add(_authStatus);
      _errorController.add(null);

      // Opcional: Si la respuesta incluye la URL de la foto, actualizar el usuario
      // Por ahora, solo marcamos como exitoso y dejamos que la UI refresque

      return true;
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en uploadProfilePhoto: ${e.message}');
      _authStatus = AuthStatus.authenticated; // Mantener autenticado aunque falle la subida
      _authController.add(_authStatus);
      _errorController.add(e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en uploadProfilePhoto: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _authStatus = AuthStatus.authenticated; // Mantener autenticado aunque falle la subida
      _authController.add(_authStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      return false;
    }
  }

  void dispose() {
    _authController.close();
    _userController.close();
    _errorController.close();
  }
}

// Instancia global del AuthBloc
final authBloc = AuthBloc();

