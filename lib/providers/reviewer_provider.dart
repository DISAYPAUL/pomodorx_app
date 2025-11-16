import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

class ReviewerProvider extends ChangeNotifier {
  ReviewerProvider(this._storage, this._ttsService);

  final StorageService _storage;
  final TtsService _ttsService;
  final _uuid = const Uuid();

  ReviewerCache? _current;
  bool _loading = false;

  ReviewerCache? get current => _current;
  bool get isLoading => _loading;

  Future<void> loadCached(String topicId) async {
    _loading = true;
    notifyListeners();
    _current = _storage.getCachedReviewer(topicId);
    _loading = false;
    notifyListeners();
  }

  Future<void> generateLocalReviewer(Topic topic, List<Quiz> quizzes) async {
    _loading = true;
    notifyListeners();
    final summary = _buildSummary(topic, quizzes);
    final cache = ReviewerCache(
      id: _uuid.v4(),
      topicId: topic.id,
      title: '${topic.name} Reviewer',
      body: summary,
      createdAt: DateTime.now(),
    );
    await _storage.cacheReviewer(cache);
    _current = cache;
    _loading = false;
    notifyListeners();
  }

  Future<void> speakCurrent() async {
    if (_current == null) return;
    await _ttsService.speak(_current!.body);
  }

  String _buildSummary(Topic topic, List<Quiz> quizzes) {
    final buffer = StringBuffer()
      ..writeln(topic.description)
      ..writeln('\nKey Points:');
    for (final quiz in quizzes) {
      buffer.writeln('- ${quiz.title}:');
      for (final question in quiz.questions.take(3)) {
        buffer.writeln('  • ${question.text}');
      }
    }
    return buffer.toString();
  }
}
