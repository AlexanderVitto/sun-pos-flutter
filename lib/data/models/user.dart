class User {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String role;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
