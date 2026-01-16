class TipoPasajeroModel {
  final int id;
  final String nombre;
  final String idCatTipoDescuento;
  final String nombreTipoDescuento;
  final double? cantidad;
  final int estatus;
  final int idCliente;
  final String nombreCliente;
  final String? apellidoPaternoCliente;
  final String? apellidoMaternoCliente;

  TipoPasajeroModel({
    required this.id,
    required this.nombre,
    required this.idCatTipoDescuento,
    required this.nombreTipoDescuento,
    this.cantidad,
    required this.estatus,
    required this.idCliente,
    required this.nombreCliente,
    this.apellidoPaternoCliente,
    this.apellidoMaternoCliente,
  });

  factory TipoPasajeroModel.fromJson(Map<String, dynamic> json) {
    return TipoPasajeroModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      idCatTipoDescuento: json['idCatTipoDescuento']?.toString() ?? '',
      nombreTipoDescuento: json['nombreTipoDescuento']?.toString() ?? '',
      cantidad: json['cantidad'] != null
          ? (json['cantidad'] as num).toDouble()
          : null,
      estatus: json['estatus'] as int? ?? 1,
      idCliente: json['idCliente'] as int? ?? 0,
      nombreCliente: json['nombreCliente']?.toString() ?? '',
      apellidoPaternoCliente: json['apellidoPaternoCliente']?.toString(),
      apellidoMaternoCliente: json['apellidoMaternoCliente']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'idCatTipoDescuento': idCatTipoDescuento,
      'nombreTipoDescuento': nombreTipoDescuento,
      'cantidad': cantidad,
      'estatus': estatus,
      'idCliente': idCliente,
      'nombreCliente': nombreCliente,
      'apellidoPaternoCliente': apellidoPaternoCliente,
      'apellidoMaternoCliente': apellidoMaternoCliente,
    };
  }

  /// Obtiene el nombre completo del cliente
  String get nombreClienteCompleto {
    final partes = [
      nombreCliente,
      apellidoPaternoCliente,
      apellidoMaternoCliente,
    ].where((parte) => parte != null && parte!.isNotEmpty).toList();
    return partes.isEmpty ? nombreCliente : partes.join(' ');
  }
}

