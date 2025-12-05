import 'package:dashboardpro/model/auth/rol.dart';
import 'package:dashboardpro/model/auth/permiso.dart';
import 'package:dashboardpro/model/auth/login_response.dart';

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

  factory User.fromLoginResponse(LoginResponse loginResponse) {
    return User(
      id: loginResponse.id,
      nombre: loginResponse.nombre,
      apellidoPaterno: loginResponse.apellidoPaterno,
      apellidoMaterno: loginResponse.apellidoMaterno,
      idCliente: loginResponse.idCliente,
      nombreCliente: loginResponse.nombreCliente,
      apellidoPaternoCliente: loginResponse.apellidoPaternoCliente,
      apellidoMaternoCliente: loginResponse.apellidoMaternoCliente,
      logotipo: loginResponse.logotipo,
      telefono: loginResponse.telefono,
      ultimoLogin: loginResponse.ultimoLogin,
      fechaCreacion: loginResponse.fechaCreacion,
      fotoPerfil: loginResponse.fotoPerfil,
      userName: loginResponse.userName,
      rol: loginResponse.rol,
      permisos: loginResponse.permisos,
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
      apellidoPaternoCliente: json['apellidoPaternoCliente']?.toString(),
      apellidoMaternoCliente: json['apellidoMaternoCliente']?.toString(),
      logotipo: json['logotipo']?.toString(),
      telefono: json['telefono']?.toString(),
      ultimoLogin: json['ultimoLogin']?.toString(),
      fechaCreacion: json['fechaCreacion']?.toString(),
      fotoPerfil: json['fotoPerfil']?.toString(),
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
}
