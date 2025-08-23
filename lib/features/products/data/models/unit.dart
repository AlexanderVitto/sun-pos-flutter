class Unit {
  final int id;
  final String name;
  final String symbol;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Unit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Unit(id: $id, name: $name, symbol: $symbol, description: $description, isActive: $isActive)';
  }
}
