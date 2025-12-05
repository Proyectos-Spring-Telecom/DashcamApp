import 'dart:async';
import 'package:dashboardpro/model/auth/user.dart';
import 'package:dashboardpro/services/auth_service.dart';
import 'package:dashboardpro/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';

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
  }

  void dispose() {
    _authController.close();
    _userController.close();
    _errorController.close();
  }
}

// Instancia global del AuthBloc
final authBloc = AuthBloc();

