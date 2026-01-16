import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:geolocator/geolocator.dart' as geo;

/// Helper para solicitar permisos de ubicación
/// Usa el diálogo nativo del sistema (Android/iOS/Web)
class LocationPermissionHelper {
  /// Solicita permisos de ubicación usando el diálogo nativo del sistema
  /// Retorna true si los permisos fueron otorgados, false en caso contrario
  static Future<bool> requestLocationPermission() async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Los servicios de ubicación están deshabilitados');
        return false;
      }

      // Verificar el estado actual de los permisos
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      
      // Si los permisos ya están otorgados, retornar true
      if (permission == geo.LocationPermission.whileInUse || 
          permission == geo.LocationPermission.always) {
        debugPrint('✅ Permisos de ubicación ya otorgados');
        return true;
      }

      // Si los permisos están denegados permanentemente, no se puede solicitar
      if (permission == geo.LocationPermission.deniedForever) {
        debugPrint('⚠️ Permisos de ubicación denegados permanentemente');
        return false;
      }

      // Solicitar permisos (esto mostrará el diálogo nativo del sistema)
      debugPrint('📱 Solicitando permisos de ubicación (diálogo nativo)...');
      permission = await geo.Geolocator.requestPermission();
      
      // Verificar el resultado
      if (permission == geo.LocationPermission.whileInUse || 
          permission == geo.LocationPermission.always) {
        debugPrint('✅ Permisos de ubicación otorgados');
        return true;
      } else {
        debugPrint('⚠️ Permisos de ubicación denegados');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error al solicitar permisos de ubicación: $e');
      return false;
    }
  }

  /// Verifica si los permisos de ubicación están otorgados
  static Future<bool> hasLocationPermission() async {
    try {
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      return permission == geo.LocationPermission.whileInUse || 
             permission == geo.LocationPermission.always;
    } catch (e) {
      debugPrint('❌ Error al verificar permisos de ubicación: $e');
      return false;
    }
  }

  /// Verifica si los servicios de ubicación están habilitados
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await geo.Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('❌ Error al verificar servicios de ubicación: $e');
      return false;
    }
  }
}
