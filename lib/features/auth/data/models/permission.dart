class Permission {
  final String name;

  Permission({required this.name});

  factory Permission.fromJson(String permission) {
    return Permission(name: permission);
  }

  String toJson() => name;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
