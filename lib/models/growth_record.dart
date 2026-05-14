class GrowthRecord {
  final int? id;
  final int childId;
  final double weight;
  final double height;
  final DateTime recordDate;

  GrowthRecord({
    this.id,
    required this.childId,
    required this.weight,
    required this.height,
    required this.recordDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'weight': weight,
      'height': height,
      'record_date': recordDate.toIso8601String(),
    };
  }

  factory GrowthRecord.fromMap(Map<String, dynamic> map) {
    return GrowthRecord(
      id: map['id'] as int?,
      childId: map['child_id'] as int,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      recordDate: DateTime.parse(map['record_date'] as String),
    );
  }
}
