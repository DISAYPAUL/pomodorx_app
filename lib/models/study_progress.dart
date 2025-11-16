class StudyProgress {
  final DateTime date;
  final int totalMinutes;
  final int sessionsCompleted;

  StudyProgress({
    required this.date,
    required this.totalMinutes,
    required this.sessionsCompleted,
  });

  // Returns date without time component for daily grouping
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalMinutes': totalMinutes,
      'sessionsCompleted': sessionsCompleted,
    };
  }

  factory StudyProgress.fromJson(Map<String, dynamic> json) {
    return StudyProgress(
      date: DateTime.parse(json['date']),
      totalMinutes: json['totalMinutes'],
      sessionsCompleted: json['sessionsCompleted'],
    );
  }

  StudyProgress copyWith({
    DateTime? date,
    int? totalMinutes,
    int? sessionsCompleted,
  }) {
    return StudyProgress(
      date: date ?? this.date,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }
}
