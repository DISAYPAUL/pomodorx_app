import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../models/quiz_analytics.dart';
import '../services/storage_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider(this._storage);

  final StorageService _storage;
  final _uuid = const Uuid();
  final _random = Random();

  List<Quiz> _quizzes = [];
  Quiz? _activeQuiz;
  int _currentIndex = 0;
  final Map<String, int> _answers = {};
  bool _loading = false;

  bool get isLoading => _loading;
  List<Quiz> get quizzes => _quizzes;
  Quiz? get activeQuiz => _activeQuiz;
  int get currentIndex => _currentIndex;
  Map<String, int> get answers => _answers;

  Question? get currentQuestion {
    if (_activeQuiz == null) return null;
    if (_currentIndex >= _activeQuiz!.questions.length) return null;
    return _activeQuiz!.questions[_currentIndex];
  }

  Future<void> loadQuizzes(String topicId) async {
    _loading = true;
    notifyListeners();
    _quizzes = await _storage.getQuizzesByTopic(topicId);
    _loading = false;
    notifyListeners();
  }

  Quiz buildCustomQuiz(Quiz baseQuiz, int questionCount) {
    final available = baseQuiz.questions.length;
    final targetCount = questionCount.clamp(1, available);
    final pool = List<Question>.from(baseQuiz.questions);
    pool.shuffle(_random);
    final selected = pool.take(targetCount).toList();
    final duration = baseQuiz.durationMinutes ?? (available * 2);
    final perQuestion = duration / available;
    final computedDuration = max(5, (perQuestion * targetCount).round());
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return Quiz(
      id: '${baseQuiz.id}-custom-$targetCount-$timestamp',
      topicId: baseQuiz.topicId,
      title: '${baseQuiz.title} ($targetCount Qs)',
      durationMinutes: computedDuration,
      questions: selected,
      createdAt: DateTime.now(),
      isOffline: true,
    );
  }

  void startQuiz(Quiz quiz) {
    // When starting a quiz, pick a random variant for each question so repeated
    // attempts of the same quiz/topic/difficulty will show different stems.
    final seed = DateTime.now().microsecondsSinceEpoch;
    final rng = Random(seed);
    final transformed = quiz.questions.map((q) {
      if (q.variants != null && q.variants!.isNotEmpty) {
        final idx = rng.nextInt(q.variants!.length);
        return Question(
          id: q.id,
          quizId: q.quizId,
          text: q.variants![idx],
          options: q.options,
          correctIndex: q.correctIndex,
          explanation: q.explanation,
          type: q.type,
        );
      }
      return q;
    }).toList();
    _activeQuiz = Quiz(
      id: quiz.id,
      topicId: quiz.topicId,
      title: quiz.title,
      durationMinutes: quiz.durationMinutes,
      questions: transformed,
      createdAt: quiz.createdAt,
      isOffline: quiz.isOffline,
    );
    _currentIndex = 0;
    _answers.clear();
    notifyListeners();
  }

  void nextQuestion() {
    if (_activeQuiz == null) return;
    if (_currentIndex < _activeQuiz!.questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void selectAnswer(String questionId, int index) {
    _answers[questionId] = index;
    notifyListeners();
  }

  bool get isQuizCompleted {
    if (_activeQuiz == null) return false;
    return _answers.length == _activeQuiz!.questions.length;
  }

  Future<UserProgress?> submitQuiz() async {
    final quiz = _activeQuiz;
    if (quiz == null) return null;
    if (_storage.getQuizById(quiz.id) == null) {
      await _storage.saveQuiz(quiz);
    }
    int score = 0;
    final answers = <ProgressAnswer>[];
    for (final question in quiz.questions) {
      final selected = _answers[question.id];
      final correct = selected == question.correctIndex;
      if (correct) score++;
      answers.add(
        ProgressAnswer(
          questionId: question.id,
          selectedIndex: selected ?? -1,
          correct: correct,
        ),
      );
    }
    final progress = UserProgress(
      id: _uuid.v4(),
      quizId: quiz.id,
      score: score,
      maxScore: quiz.questions.length,
      answers: answers,
      attemptedAt: DateTime.now(),
    );
    await _storage.saveProgress(progress);
    return progress;
  }

  Future<List<UserProgress>> historyForQuiz(String quizId) {
    return _storage.getProgressForQuiz(quizId);
  }

  Future<QuizAnalytics?> buildQuizAnalytics(String quizId) async {
    final history = await historyForQuiz(quizId);
    if (history.isEmpty) return null;
    history.sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
    final allQuizzes = await _storage.getAllQuizzes();
    final questionIndex = <String, Question>{
      for (final quiz in allQuizzes)
        for (final question in quiz.questions) question.id: question,
    };
    final aggregates = <String, _QuestionAggregate>{};
    for (final progress in history) {
      for (final answer in progress.answers) {
        final aggregate = aggregates.putIfAbsent(
          answer.questionId,
          () => _QuestionAggregate(questionIndex[answer.questionId]),
        );
        aggregate.attempts += 1;
        if (answer.correct) aggregate.correct += 1;
        if (aggregate.lastAttempt == null ||
            aggregate.lastAttempt!.isBefore(progress.attemptedAt)) {
          aggregate.lastAttempt = progress.attemptedAt;
        }
      }
    }

    final insights =
        aggregates.entries
            .map((entry) => _buildInsight(entry.key, entry.value))
            .whereType<QuestionInsight>()
            .toList()
          ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    final lowAccuracy = insights
        .where((insight) => insight.accuracy < 0.8)
        .take(3)
        .toList();
    final focusAreas = lowAccuracy.length >= 3
        ? lowAccuracy
        : (lowAccuracy +
                  insights
                      .where((insight) => !lowAccuracy.contains(insight))
                      .take(3 - lowAccuracy.length)
                      .toList())
              .take(3)
              .toList();
    final scoreFractions = history
        .map((item) => item.maxScore == 0 ? 0.0 : item.score / item.maxScore)
        .toList();
    final latestPercent = scoreFractions.first;
    final bestPercent = scoreFractions.reduce((a, b) => a > b ? a : b);
    final averagePercent =
        scoreFractions.reduce((a, b) => a + b) / scoreFractions.length;
    final totalItems = history.fold<int>(
      0,
      (sum, item) => sum + item.answers.length,
    );

    return QuizAnalytics(
      history: history,
      latestPercent: latestPercent,
      bestPercent: bestPercent,
      averagePercent: averagePercent,
      totalAttempts: history.length,
      totalItemsAnswered: totalItems,
      uniqueQuestions: aggregates.length,
      focusAreas: focusAreas,
    );
  }

  Future<GlobalAnalytics?> buildGlobalAnalytics() async {
    final allProgress = await _storage.getAllProgress();
    if (allProgress.isEmpty) return null;

    final allQuizzes = await _storage.getAllQuizzes();
    if (allQuizzes.isEmpty) return null;
    final quizById = {for (final quiz in allQuizzes) quiz.id: quiz};

    final topics = await _storage.getAllTopics();
    final topicById = {for (final topic in topics) topic.id: topic};

    final topicAggregates = <String, _TopicAggregate>{};
    double overallPercentSum = 0.0;
    double bestPercent = 0.0;
    DateTime? lastAttempt;

    for (final progress in allProgress) {
      final quiz = quizById[progress.quizId];
      if (quiz == null) continue;
      final percent = progress.maxScore == 0
          ? 0.0
          : progress.score / progress.maxScore;
      overallPercentSum += percent;
      if (percent > bestPercent) {
        bestPercent = percent;
      }
      if (lastAttempt == null) {
        lastAttempt = progress.attemptedAt;
      } else if (progress.attemptedAt.isAfter(lastAttempt)) {
        lastAttempt = progress.attemptedAt;
      }

      final topicId = quiz.topicId;
      final topicAggregate = topicAggregates.putIfAbsent(
        topicId,
        () => _TopicAggregate(
          topicId: topicId,
          topicName: topicById[topicId]?.name ?? 'Untitled topic',
        ),
      );
      topicAggregate.totalAttempts += 1;
      topicAggregate.percentSum += percent;
      final lastForTopic = topicAggregate.lastAttempt;
      if (lastForTopic == null || progress.attemptedAt.isAfter(lastForTopic)) {
        topicAggregate.lastAttempt = progress.attemptedAt;
      }
      topicAggregate.addDifficulty(
        slug: quiz.difficultySlug,
        label: quiz.difficultyLabel,
        percent: percent,
      );
    }

    if (topicAggregates.isEmpty) return null;

    final topicStats =
        topicAggregates.values
            .map((aggregate) => aggregate.toTopicPerformance())
            .toList()
          ..sort((a, b) => b.totalAttempts.compareTo(a.totalAttempts));

    final averagePercent = overallPercentSum / allProgress.length;

    return GlobalAnalytics(
      totalAttempts: allProgress.length,
      averagePercent: averagePercent,
      bestPercent: bestPercent,
      lastAttempt: lastAttempt,
      topicStats: topicStats,
    );
  }

  QuestionInsight? _buildInsight(
    String questionId,
    _QuestionAggregate aggregate,
  ) {
    final question = aggregate.question;
    if (question == null) return null;
    return QuestionInsight(
      questionId: questionId,
      questionText: question.text,
      explanation: question.explanation,
      attempts: aggregate.attempts,
      correct: aggregate.correct,
      lastAttempt: aggregate.lastAttempt ?? DateTime.now(),
    );
  }
}

class _QuestionAggregate {
  _QuestionAggregate(this.question);

  final Question? question;
  int attempts = 0;
  int correct = 0;
  DateTime? lastAttempt;
}

class _TopicAggregate {
  _TopicAggregate({required this.topicId, required this.topicName});

  final String topicId;
  final String topicName;
  int totalAttempts = 0;
  double percentSum = 0.0;
  DateTime? lastAttempt;
  final Map<String, _DifficultyAggregate> difficulties = {};

  void addDifficulty({
    required String slug,
    required String label,
    required double percent,
  }) {
    final aggregate = difficulties.putIfAbsent(
      slug,
      () => _DifficultyAggregate(slug: slug, label: label),
    );
    aggregate.totalAttempts += 1;
    aggregate.percentSum += percent;
    if (percent > aggregate.bestPercent) {
      aggregate.bestPercent = percent;
    }
  }

  TopicPerformance toTopicPerformance() {
    final stats =
        difficulties.values
            .map((diff) => diff.toDifficultyPerformance())
            .toList()
          ..sort((a, b) => b.attempts.compareTo(a.attempts));
    final average = totalAttempts == 0 ? 0.0 : percentSum / totalAttempts;
    return TopicPerformance(
      topicId: topicId,
      topicName: topicName,
      totalAttempts: totalAttempts,
      averagePercent: average,
      lastAttempt: lastAttempt,
      difficultyStats: stats,
    );
  }
}

class _DifficultyAggregate {
  _DifficultyAggregate({required this.slug, required this.label});

  final String slug;
  final String label;
  int totalAttempts = 0;
  double percentSum = 0.0;
  double bestPercent = 0.0;

  DifficultyPerformance toDifficultyPerformance() {
    final average = totalAttempts == 0 ? 0.0 : percentSum / totalAttempts;
    return DifficultyPerformance(
      slug: slug,
      label: label,
      attempts: totalAttempts,
      averagePercent: average,
      bestPercent: bestPercent,
    );
  }
}
