import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:dashboardpro/model/auth/user.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _userKey = 'user_data';

  /// Guarda el token de autenticación
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Error al guardar el token: $e');
    }
  }

  /// Obtiene el token de autenticación
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Error al leer el token: $e');
    }
  }

  /// Guarda el refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw Exception('Error al guardar el refresh token: $e');
    }
  }

  /// Obtiene el refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Error al leer el refresh token: $e');
    }
  }

  /// Guarda la información del usuario
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw Exception('Error al guardar el usuario: $e');
    }
  }

  /// Obtiene la información del usuario
  Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null) return null;
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      throw Exception('Error al leer el usuario: $e');
    }
  }

  /// Elimina el token y la información del usuario (logout)
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      throw Exception('Error al limpiar el almacenamiento: $e');
    }
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

