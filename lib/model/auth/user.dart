import 'package:dashboardpro/model/auth/rol.dart';
import 'package:dashboardpro/model/auth/permiso.dart';
import 'package:dashboardpro/model/auth/login_response.dart';
import 'package:dashboardpro/utils/auth_rol_helper.dart';
import 'package:dashboardpro/utils/jwt_payload_helper.dart';

class User {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final int idCliente;
  final String nombreCliente;
  final String? apellidoPaternoCliente;
  final String? apellidoMaternoCliente;
  final String? logotipo;
  final String? telefono;
  final String? ultimoLogin;
  final String? fechaCreacion;
  final String? fotoPerfil;
  final String userName;
  final Rol? rol;
  final List<Permiso> permisos;

  User({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.idCliente,
    required this.nombreCliente,
    this.apellidoPaternoCliente,
    this.apellidoMaternoCliente,
    this.logotipo,
    this.telefono,
    this.ultimoLogin,
    this.fechaCreacion,
    this.fotoPerfil,
    required this.userName,
    this.rol,
    required this.permisos,
  });

  factory User.fromLoginResponse(
    LoginResponse loginResponse, {
    required String userName,
  }) {
    return User.fromAccessToken(loginResponse.token, userName: userName);
  }

  /// Construye un [User] mínimo a partir de los claims del JWT de acceso.
  factory User.fromAccessToken(String token, {required String userName}) {
    final claims = JwtPayloadHelper.decodePayload(token);
    final email = claims['email']?.toString().trim();
    final resolvedUserName =
        (email != null && email.isNotEmpty) ? email : userName.trim();

    final id = int.tryParse(claims['id']?.toString() ?? '') ?? 0;
    final idCliente =
        int.tryParse(claims['cliente']?.toString() ?? '') ?? 0;
    final rolId = claims['rol']?.toString() ?? '';
    final rolNombre = AuthRolHelper.nombreFromId(rolId);

    final displayName = resolvedUserName.contains('@')
        ? resolvedUserName.split('@').first
        : resolvedUserName;

    return User(
      id: id,
      nombre: displayName,
      apellidoPaterno: '',
      apellidoMaterno: '',
      idCliente: idCliente,
      nombreCliente: '',
      userName: resolvedUserName,
      rol: rolId.isNotEmpty
          ? Rol(
              id: rolId,
              nombre: rolNombre,
              descripcion: '',
              estatus: 1,
            )
          : null,
      permisos: const [],
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellidoPaterno: json['apellidoPaterno']?.toString() ?? '',
      apellidoMaterno: json['apellidoMaterno']?.toString() ?? '',
      idCliente: json['idCliente'] ?? 0,
      nombreCliente: json['nombreCliente']?.toString() ?? '',
      apellidoPaternoCliente: _optionalString(json['apellidoPaternoCliente']),
      apellidoMaternoCliente: _optionalString(json['apellidoMaternoCliente']),
      logotipo: _optionalString(json['logotipo']),
      telefono: _optionalString(json['telefono']),
      ultimoLogin: _optionalString(json['ultimoLogin']),
      fechaCreacion: _optionalString(json['fechaCreacion']),
      fotoPerfil: _optionalString(json['fotoPerfil']),
      userName: json['userName']?.toString() ?? '',
      rol: json['rol'] != null ? Rol.fromJson(json['rol'] as Map<String, dynamic>) : null,
      permisos: json['permisos'] != null
          ? (json['permisos'] as List)
              .map((permiso) => Permiso.fromJson(permiso as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'idCliente': idCliente,
      'nombreCliente': nombreCliente,
      'apellidoPaternoCliente': apellidoPaternoCliente,
      'apellidoMaternoCliente': apellidoMaternoCliente,
      'logotipo': logotipo,
      'telefono': telefono,
      'ultimoLogin': ultimoLogin,
      'fechaCreacion': fechaCreacion,
      'fotoPerfil': fotoPerfil,
      'userName': userName,
      'rol': rol?.toJson(),
      'permisos': permisos.map((permiso) => permiso.toJson()).toList(),
    };
  }

  // Método helper para obtener el nombre completo
  String get nombreCompleto {
    return '$nombre $apellidoPaterno $apellidoMaterno'.trim();
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }
}
