class PaginacionModel {
  final int total;
  final int page;
  final int lastPage;

  PaginacionModel({
    required this.total,
    required this.page,
    required this.lastPage,
  });

  factory PaginacionModel.fromJson(Map<String, dynamic> json) {
    // Manejar valores que pueden venir como int o num
    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final total = parseToInt(json['total']);
    final page = parseToInt(json['page']);
    final lastPage = parseToInt(json['lastPage']);

    return PaginacionModel(
      total: total,
      page: page > 0 ? page : 1,
      lastPage: lastPage > 0 ? lastPage : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'lastPage': lastPage,
    };
  }
}

