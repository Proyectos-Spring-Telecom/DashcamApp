import 'dart:async';

import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/model/auth/login_response.dart';
import 'package:dashboardpro/services/auth_api_service.dart';
import 'package:dashboardpro/services/secure_storage_service.dart';

/// Coordina el refresh de tokens con un único in-flight request (evita carreras).
class TokenRefreshService {
  TokenRefreshService._();

  static const String retriedExtraKey = 'auth_retried';

  static final SecureStorageService _storage = SecureStorageService();
  static Future<LoginResponse>? _inFlightRefresh;

  /// Renueva access + refresh token usando el refresh token almacenado.
  /// Retorna `null` si no hay refresh token o si la renovación falla.
  static Future<LoginResponse?> refreshSession() async {
    if (_inFlightRefresh != null) {
      try {
        return await _inFlightRefresh!;
      } catch (e) {
        return null;
      }
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    _inFlightRefresh = _performRefresh(refreshToken);
    try {
      return await _inFlightRefresh!;
    } catch (e) {
      return null;
    } finally {
      _inFlightRefresh = null;
    }
  }

  static Future<LoginResponse> _performRefresh(String refreshToken) async {

    final tokens = await AuthApiService.refreshTokens(refreshToken: refreshToken);
    await authBloc.applyRefreshedTokens(tokens);


    return tokens;
  }
}
