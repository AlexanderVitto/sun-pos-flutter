import 'role.dart';

class User {
  final int id;
  final String name;
  final String email;
  final List<Role> roles;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var rolesList = json['roles'] as List<dynamic>? ?? [];
    List<Role> roles =
        rolesList
            .map((roleJson) => Role.fromJson(roleJson as Map<String, dynamic>))
            .toList();

    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: roles,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles.map((role) => role.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Get role names as list of strings (for backward compatibility)
  List<String> get roleNames {
    return roles.map((role) => role.name).toList();
  }

  /// Get all permissions from all roles
  List<String> get allPermissions {
    Set<String> permissionSet = {};
    for (Role role in roles) {
      permissionSet.addAll(role.permissionNames);
    }
    return permissionSet.toList();
  }

  /// Check if user has a specific permission
  bool hasPermission(String permissionName) {
    return roles.any((role) => role.hasPermission(permissionName));
  }

  /// Check if user has a specific role
  bool hasRole(String roleName) {
    return roles.any((role) => role.name == roleName);
  }

  /// Get display names of all roles
  List<String> get roleDisplayNames {
    return roles.map((role) => role.displayName).toList();
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, roles: ${roleNames.join(', ')})';
  }
}
