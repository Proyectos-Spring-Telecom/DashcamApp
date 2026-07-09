/// Resuelve el nombre legible del rol a partir del ID del JWT (para menús y navegación).
class AuthRolHelper {
  AuthRolHelper._();

  /// Mapeo ID de rol → nombre usado en la UI (`cajero`, `pasajero`, `administrador`, etc.).
  /// Ampliar cuando el backend documente nuevos IDs.
  static const Map<String, String> _idToNombre = {
    // Ejemplo: '3': 'cajero',
  };

  static String nombreFromId(dynamic rolId) {
    final id = rolId?.toString().trim() ?? '';
    if (id.isEmpty) return '';
    return _idToNombre[id] ?? '';
  }
}
