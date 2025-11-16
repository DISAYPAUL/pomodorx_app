enum SessionType {
  work,
  shortBreak,
  longBreak,
}

enum TimerStatus {
  initial,
  running,
  paused,
  completed,
}

class PomodoroSession {
  final SessionType type;
  final int durationInSeconds;
  final DateTime startTime;
  DateTime? endTime;

  PomodoroSession({
    required this.type,
    required this.durationInSeconds,
    required this.startTime,
    this.endTime,
  });

  bool get isCompleted => endTime != null;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'durationInSeconds': durationInSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      type: SessionType.values.firstWhere((e) => e.name == json['type']),
      durationInSeconds: json['durationInSeconds'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}

class PomodoroSettings {
  final int workDuration; // in minutes
  final int shortBreakDuration; // in minutes
  final int longBreakDuration; // in minutes
  final int sessionsUntilLongBreak;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;

  const PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsUntilLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
  });

  PomodoroSettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'sessionsUntilLongBreak': sessionsUntilLongBreak,
      'autoStartBreaks': autoStartBreaks,
      'autoStartPomodoros': autoStartPomodoros,
    };
  }

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      workDuration: json['workDuration'] ?? 25,
      shortBreakDuration: json['shortBreakDuration'] ?? 5,
      longBreakDuration: json['longBreakDuration'] ?? 15,
      sessionsUntilLongBreak: json['sessionsUntilLongBreak'] ?? 4,
      autoStartBreaks: json['autoStartBreaks'] ?? false,
      autoStartPomodoros: json['autoStartPomodoros'] ?? false,
    );
  }
}
