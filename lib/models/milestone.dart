class Milestone {
  final int? id;
  final String category; // motorik, kognitif, bahasa, sosial_emosional
  final String subcategory; // e.g., motorik_kasar, motorik_halus
  final int ageMonthsMin;
  final int ageMonthsMax;
  final String description;
  final String? icon;

  Milestone({
    this.id,
    required this.category,
    required this.subcategory,
    required this.ageMonthsMin,
    required this.ageMonthsMax,
    required this.description,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'age_months_min': ageMonthsMin,
      'age_months_max': ageMonthsMax,
      'description': description,
      'icon': icon,
    };
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'] as int?,
      category: map['category'] as String,
      subcategory: map['subcategory'] as String,
      ageMonthsMin: map['age_months_min'] as int,
      ageMonthsMax: map['age_months_max'] as int,
      description: map['description'] as String,
      icon: map['icon'] as String?,
    );
  }
}

class MilestoneRecord {
  final int? id;
  final int childId;
  final int milestoneId;
  final bool isAchieved;
  final DateTime? achievedDate;
  final int recordMonth; // the month when this was recorded

  MilestoneRecord({
    this.id,
    required this.childId,
    required this.milestoneId,
    required this.isAchieved,
    this.achievedDate,
    required this.recordMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'milestone_id': milestoneId,
      'is_achieved': isAchieved ? 1 : 0,
      'achieved_date': achievedDate?.toIso8601String(),
      'record_month': recordMonth,
    };
  }

  factory MilestoneRecord.fromMap(Map<String, dynamic> map) {
    return MilestoneRecord(
      id: map['id'] as int?,
      childId: map['child_id'] as int,
      milestoneId: map['milestone_id'] as int,
      isAchieved: (map['is_achieved'] as int) == 1,
      achievedDate: map['achieved_date'] != null
          ? DateTime.parse(map['achieved_date'] as String)
          : null,
      recordMonth: map['record_month'] as int,
    );
  }
}
