import 'permission.dart';

class Role {
  final int id;
  final String name;
  final String displayName;
  final String guardName;
  final List<Permission> permissions;
  final String createdAt;
  final String updatedAt;

  Role({
    required this.id,
    required this.name,
    required this.displayName,
    required this.guardName,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    var permissionsList = json['permissions'] as List<dynamic>? ?? [];
    List<Permission> permissions =
        permissionsList
            .map((permission) => Permission.fromJson(permission as String))
            .toList();

    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      guardName: json['guard_name'] ?? '',
      permissions: permissions,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'guard_name': guardName,
      'permissions': permissions.map((p) => p.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if this role has a specific permission
  bool hasPermission(String permissionName) {
    return permissions.any((permission) => permission.name == permissionName);
  }

  /// Get all permission names as list of strings
  List<String> get permissionNames {
    return permissions.map((p) => p.name).toList();
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name, displayName: $displayName, permissions: ${permissions.length})';
  }
}
