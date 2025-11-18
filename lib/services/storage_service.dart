import '../models/models.dart';
import 'hive_service.dart';

class StorageService {
  StorageService(this._hiveService);

  final HiveService _hiveService;

  Future<List<Topic>> getAllTopics() async {
    return _hiveService.topicsBox.values.toList();
  }

  Future<void> saveTopics(List<Topic> topics) async {
    final box = _hiveService.topicsBox;
    await box.clear();
    final entries = {for (final topic in topics) topic.id: topic};
    await box.putAll(entries);
  }

  Future<List<Quiz>> getQuizzesByTopic(String topicId) async {
    return _hiveService.quizzesBox.values
        .where((quiz) => quiz.topicId == topicId)
        .toList();
  }

  Future<void> saveQuiz(Quiz quiz) async {
    await _hiveService.quizzesBox.put(quiz.id, quiz);
  }

  Future<List<Quiz>> getAllQuizzes() async {
    return _hiveService.quizzesBox.values.toList();
  }

  Quiz? getQuizById(String quizId) {
    return _hiveService.quizzesBox.get(quizId);
  }

  Future<void> saveQuizzes(List<Quiz> quizzes) async {
    final box = _hiveService.quizzesBox;
    await box.putAll({for (final quiz in quizzes) quiz.id: quiz});
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _hiveService.progressBox.put(progress.id, progress);
  }

  Future<List<UserProgress>> getProgressForQuiz(String quizId) async {
    return _hiveService.progressBox.values
        .where((progress) => progress.quizId == quizId)
        .toList();
  }

  Future<List<UserProgress>> getAllProgress() async {
    return _hiveService.progressBox.values.toList();
  }

  Future<void> cacheReviewer(ReviewerCache reviewer) async {
    await _hiveService.reviewersBox.put(reviewer.topicId, reviewer);
  }

  ReviewerCache? getCachedReviewer(String topicId) {
    return _hiveService.reviewersBox.get(topicId);
  }
}
