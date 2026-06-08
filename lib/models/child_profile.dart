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

  /// WHO weight-for-age median (kg) by age in months (0–24).
  /// Source: WHO Child Growth Standards (simplified median for boys/girls avg).
  static const List<double> _whoWeightMedian = [
    3.3,  // 0 months
    4.5,  // 1
    5.6,  // 2
    6.4,  // 3
    7.0,  // 4
    7.5,  // 5
    7.9,  // 6
    8.3,  // 7
    8.6,  // 8
    8.9,  // 9
    9.2,  // 10
    9.4,  // 11
    9.6,  // 12
    9.9,  // 13
    10.1, // 14
    10.3, // 15
    10.5, // 16
    10.7, // 17
    10.9, // 18
    11.1, // 19
    11.3, // 20
    11.5, // 21
    11.8, // 22
    12.0, // 23
    12.2, // 24
  ];

  String get nutritionStatus {
    if (weight == null) return 'Belum diukur';
    final months = ageInMonths.clamp(0, 24);
    final median = _whoWeightMedian[months];
    // WHO z-score approximation: ≤ -2 SD ≈ < 80% median, ≥ +2 SD ≈ > 120% median
    if (weight! < median * 0.80) return 'Gizi Kurang';
    if (weight! > median * 1.20) return 'Gizi Lebih';
    return 'Gizi Baik';
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
