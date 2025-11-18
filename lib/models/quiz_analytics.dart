import 'progress.dart';

class QuestionInsight {
  QuestionInsight({
    required this.questionId,
    required this.questionText,
    required this.explanation,
    required this.attempts,
    required this.correct,
    required this.lastAttempt,
  });

  final String questionId;
  final String questionText;
  final String? explanation;
  final int attempts;
  final int correct;
  final DateTime lastAttempt;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;
}

class DifficultyPerformance {
  DifficultyPerformance({
    required this.slug,
    required this.label,
    required this.attempts,
    required this.averagePercent,
    required this.bestPercent,
  });

  final String slug;
  final String label;
  final int attempts;
  final double averagePercent;
  final double bestPercent;
}

class TopicPerformance {
  TopicPerformance({
    required this.topicId,
    required this.topicName,
    required this.totalAttempts,
    required this.averagePercent,
    required this.lastAttempt,
    required this.difficultyStats,
  });

  final String topicId;
  final String topicName;
  final int totalAttempts;
  final double averagePercent;
  final DateTime? lastAttempt;
  final List<DifficultyPerformance> difficultyStats;
}

class GlobalAnalytics {
  GlobalAnalytics({
    required this.totalAttempts,
    required this.averagePercent,
    required this.bestPercent,
    required this.lastAttempt,
    required this.topicStats,
  });

  final int totalAttempts;
  final double averagePercent;
  final double bestPercent;
  final DateTime? lastAttempt;
  final List<TopicPerformance> topicStats;

  bool get hasData => totalAttempts > 0;
}

class QuizAnalytics {
  QuizAnalytics({
    required this.history,
    required this.latestPercent,
    required this.bestPercent,
    required this.averagePercent,
    required this.totalAttempts,
    required this.totalItemsAnswered,
    required this.uniqueQuestions,
    required this.focusAreas,
  });

  final List<UserProgress> history;
  final double latestPercent;
  final double bestPercent;
  final double averagePercent;
  final int totalAttempts;
  final int totalItemsAnswered;
  final int uniqueQuestions;
  final List<QuestionInsight> focusAreas;
}
