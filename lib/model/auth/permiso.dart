class Permiso {
  final String idPermiso;

  Permiso({
    required this.idPermiso,
  });

  factory Permiso.fromJson(Map<String, dynamic> json) {
    return Permiso(
      idPermiso: json['idPermiso']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPermiso': idPermiso,
    };
  }
}

