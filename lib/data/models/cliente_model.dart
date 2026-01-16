import 'package:dashboardpro/domain/entities/cliente_entity.dart';

/// Modelo de datos para Cliente
/// Extiende la entidad de dominio
class ClienteModel extends ClienteEntity {
  final String nombre;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? logotipo;
  final int? estatus;

  ClienteModel({
    required super.id,
    required this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.logotipo,
    this.estatus,
  }) : super(
          nombreCompleto: _buildNombreCompleto(
            nombre,
            apellidoPaterno,
            apellidoMaterno,
          ),
        );

  /// Construye el nombre completo del cliente
  static String _buildNombreCompleto(
    String nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
  ) {
    final partes = [
      nombre,
      apellidoPaterno,
      apellidoMaterno,
    ].where((parte) => parte != null && parte!.isNotEmpty).toList();
    return partes.isEmpty ? nombre : partes.join(' ');
  }

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellidoPaterno: json['apellidoPaterno']?.toString(),
      apellidoMaterno: json['apellidoMaterno']?.toString(),
      logotipo: json['logotipo']?.toString(),
      estatus: json['estatus'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'logotipo': logotipo,
      'estatus': estatus,
    };
  }

  /// Verifica si el cliente está activo
  bool get isActivo => estatus == 1;
}
