import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:geolocator/geolocator.dart' as geo;

import 'package:dashboardpro/utils/location_permission_helper.dart';

/// Resultado de obtener coordenadas: solo se retorna si son double válidos (finitos).
class CoordenadasValidas {
  final double latitud;
  final double longitud;

  const CoordenadasValidas({required this.latitud, required this.longitud});

  Map<String, double> toMap() => {'latitud': latitud, 'longitud': longitud};
}

/// Helper robusto para obtener ubicación en Flutter Web y PWA (incl. iOS Add to Home Screen).
/// - Verifica/solicita permisos explícitamente antes de obtener posición (importante en PWA iOS).
/// - Valida que lat/lng sean double finitos (no null, no NaN, no infinity).
/// - Logs detallados para depuración.
class LocationHelper {
  /// Timeout para getCurrentPosition (PWA puede tardar más).
  static const Duration positionTimeout = Duration(seconds: 15);

  /// Comprueba si un valor es un double válido para enviar al backend (no null, no NaN, finito).
  static bool isValidCoordinate(double? value) {
    if (value == null) return false;
    return value.isFinite && !value.isNaN;
  }

  /// Convierte un valor a double válido o null (para no enviar NaN/Infinity al backend).
  static double? toValidDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value.isFinite && !value.isNaN ? value : null;
    if (value is int) return value.toDouble();
    if (value is num) {
      final d = value.toDouble();
      return d.isFinite && !d.isNaN ? d : null;
    }
    if (value is String) {
      final d = double.tryParse(value);
      return d != null && d.isFinite && !d.isNaN ? d : null;
    }
    return null;
  }

  /// Verifica permisos y, si es necesario, los solicita (recomendado antes de recarga en PWA iOS).
  /// Retorna true si hay permisos para obtener ubicación.
  static Future<bool> ensureLocationPermission() async {
    try {
      final hasPermission = await LocationPermissionHelper.hasLocationPermission();
      if (hasPermission) {
        debugPrint('📍 [LocationHelper] Permisos de ubicación ya otorgados.');
        return true;
      }
      debugPrint('📍 [LocationHelper] Permisos no otorgados, solicitando...');
      return await LocationPermissionHelper.requestLocationPermission();
    } catch (e) {
      debugPrint('❌ [LocationHelper] Error al verificar/solicitar permisos: $e');
      return false;
    }
  }

  /// Obtiene la ubicación actual con validación robusta para Web/PWA.
  /// - En PWA iOS es importante llamar a [ensureLocationPermission] antes (p. ej. al iniciar recarga).
  /// Retorna [CoordenadasValidas] solo si lat/lng son double finitos; si no, null.
  static Future<CoordenadasValidas?> getValidCoordinates({
    bool requestPermissionIfNeeded = true,
  }) async {
    debugPrint('📍 [LocationHelper] getValidCoordinates() iniciado (kIsWeb=$kIsWeb, requestPermission=$requestPermissionIfNeeded)');

    try {
      if (requestPermissionIfNeeded) {
        final allowed = await ensureLocationPermission();
        if (!allowed) {
          debugPrint('⚠️ [LocationHelper] Sin permisos de ubicación. No se obtendrán coordenadas.');
          return null;
        }
      } else {
        final hasPermission = await LocationPermissionHelper.hasLocationPermission();
        if (!hasPermission) {
          debugPrint('⚠️ [LocationHelper] Permisos no otorgados (no solicitados).');
          return null;
        }
      }

      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ [LocationHelper] Servicios de ubicación deshabilitados.');
        return null;
      }

      debugPrint('📍 [LocationHelper] Obteniendo posición (timeout: ${positionTimeout.inSeconds}s)...');
      final geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: positionTimeout,
      );

      final double rawLat = position.latitude;
      final double rawLng = position.longitude;

      debugPrint('📍 [LocationHelper] Posición bruta: lat=$rawLat (isFinite=${rawLat.isFinite}, isNaN=${rawLat.isNaN}), lng=$rawLng (isFinite=${rawLng.isFinite}, isNaN=${rawLng.isNaN})');

      final double? lat = toValidDouble(rawLat);
      final double? lng = toValidDouble(rawLng);

      if (lat == null || lng == null) {
        debugPrint('❌ [LocationHelper] Coordenadas inválidas después de validación: lat=$lat, lng=$lng');
        return null;
      }

      // Rango razonable para lat/lng
      if (lat.abs() > 90 || lng.abs() > 180) {
        debugPrint('⚠️ [LocationHelper] Coordenadas fuera de rango: lat=$lat, lng=$lng');
        return null;
      }

      debugPrint('✅ [LocationHelper] Coordenadas válidas: lat=$lat, lng=$lng');
      return CoordenadasValidas(latitud: lat, longitud: lng);
    } on geo.PermissionDeniedException catch (e) {
      debugPrint('❌ [LocationHelper] Permiso denegado: $e');
      return null;
    } on geo.LocationServiceDisabledException catch (e) {
      debugPrint('❌ [LocationHelper] Servicio de ubicación deshabilitado: $e');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('❌ [LocationHelper] Timeout al obtener ubicación: $e');
      return null;
    } catch (e, st) {
      debugPrint('❌ [LocationHelper] Error al obtener ubicación: $e');
      debugPrint('📚 [LocationHelper] StackTrace: $st');
      return null;
    }
  }

  /// Versión que retorna Map<String, double>? para compatibilidad con código que espera mapa.
  /// Solo incluye entradas si los valores son double válidos.
  static Future<Map<String, double>?> getValidCoordinatesMap({
    bool requestPermissionIfNeeded = true,
  }) async {
    final coords = await getValidCoordinates(requestPermissionIfNeeded: requestPermissionIfNeeded);
    return coords?.toMap();
  }
}
