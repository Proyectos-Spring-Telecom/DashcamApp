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
        return false;
      }

      // Verificar el estado actual de los permisos
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      
      // Si los permisos ya están otorgados, retornar true
      if (permission == geo.LocationPermission.whileInUse || 
          permission == geo.LocationPermission.always) {
        return true;
      }

      // Si los permisos están denegados permanentemente, no se puede solicitar
      if (permission == geo.LocationPermission.deniedForever) {
        return false;
      }

      // Solicitar permisos (esto mostrará el diálogo nativo del sistema)
      permission = await geo.Geolocator.requestPermission();
      
      // Verificar el resultado
      if (permission == geo.LocationPermission.whileInUse || 
          permission == geo.LocationPermission.always) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
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
      return false;
    }
  }

  /// Verifica si los servicios de ubicación están habilitados
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await geo.Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }
}
