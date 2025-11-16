import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/storage_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider(this._storage);

  final StorageService _storage;
  final _uuid = const Uuid();

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

  void startQuiz(Quiz quiz) {
    _activeQuiz = quiz;
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
}
