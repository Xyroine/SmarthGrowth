class AppUser {
  final int? id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
  final String? photoPath;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    DateTime? createdAt,
    this.photoPath,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'photo_path': photoPath,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      photoPath: map['photo_path'] as String?,
    );
  }
}
