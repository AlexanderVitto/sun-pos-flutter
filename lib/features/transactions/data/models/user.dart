class User {
  final int id;
  final String name;
  final String email;
  final List<Role> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((role) => Role.fromJson(role as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles.map((role) => role.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, roles: ${roles.length})';
  }
}

class Role {
  final int id;
  final String name;
  final String displayName;
  final String guardName;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.displayName,
    required this.guardName,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      guardName: json['guard_name'] ?? '',
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((permission) => permission.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'guard_name': guardName,
      'permissions': permissions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name, displayName: $displayName, permissions: ${permissions.length})';
  }
}
