class ChildProfile {
  final int? id;
  final int userId;
  final String name;
  final String gender; // 'Laki-laki' or 'Perempuan'
  final DateTime birthDate;
  final double? weight; // kg
  final double? height; // cm
  final String? photoPath;

  ChildProfile({
    this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.weight,
    this.height,
    this.photoPath,
  });

  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months < 0 ? 0 : months;
  }

  String get ageString {
    final months = ageInMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    final days = DateTime.now().day - birthDate.day;
    final adjustedDays = days < 0 ? 30 + days : days;

    if (years > 0) {
      return '$years Tahun $remainingMonths Bulan $adjustedDays Hari';
    }
    return '$remainingMonths Bulan $adjustedDays Hari';
  }

  String get shortAgeString {
    final months = ageInMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years > 0) {
      return '$years Tahun $remainingMonths Bulan';
    }
    return '$remainingMonths Bulan';
  }

  String get nutritionStatus {
    if (weight == null || height == null) return 'Belum diukur';
    // Simple BMI-based classification for children
    final heightInM = height! / 100;
    final bmi = weight! / (heightInM * heightInM);
    if (bmi < 14) return 'Gizi Kurang';
    if (bmi < 18) return 'Gizi Baik';
    return 'Gizi Lebih';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'gender': gender,
      'birth_date': birthDate.toIso8601String(),
      'weight': weight,
      'height': height,
      'photo_path': photoPath,
    };
  }

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      gender: map['gender'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
      weight: map['weight'] as double?,
      height: map['height'] as double?,
      photoPath: map['photo_path'] as String?,
    );
  }

  ChildProfile copyWith({
    int? id,
    int? userId,
    String? name,
    String? gender,
    DateTime? birthDate,
    double? weight,
    double? height,
    String? photoPath,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
