class Reminder {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;

  Reminder({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      dateTime: DateTime.parse(map['date_time'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  Reminder copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
