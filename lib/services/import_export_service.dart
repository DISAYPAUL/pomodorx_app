import 'dart:convert';

import '../models/models.dart';
import 'hive_service.dart';
import 'storage_service.dart';

class ImportExportService {
  ImportExportService(this._storage, this._hiveService);

  final StorageService _storage;
  final HiveService _hiveService;

  Future<String> exportData() async {
    final topics = await _storage.getAllTopics();
    final quizzes = _hiveService.quizzesBox.values.toList();
    final progress = _hiveService.progressBox.values.toList();
    final reviewers = _hiveService.reviewersBox.values.toList();

    final payload = {
      'topics': topics.map((t) => t.toJson()).toList(),
      'quizzes': quizzes.map((q) => q.toJson()).toList(),
      'progress': progress.map((p) => p.toJson()).toList(),
      'reviewers': reviewers.map((r) => r.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> importData(String jsonString) async {
    final Map<String, dynamic> data = json.decode(jsonString)
        as Map<String, dynamic>;
    final topics = (data['topics'] as List<dynamic>)
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
    final quizzes = (data['quizzes'] as List<dynamic>).map((raw) {
      final map = raw as Map<String, dynamic>;
      return Quiz.fromJson(map, map['topicId'] as String);
    }).toList();
    final progress = (data['progress'] as List<dynamic>)
        .map((e) => UserProgress.fromJson(e as Map<String, dynamic>))
        .toList();
    final reviewers = (data['reviewers'] as List<dynamic>)
        .map((e) => ReviewerCache.fromJson(e as Map<String, dynamic>))
        .toList();

    await _storage.saveTopics(topics);
    await _storage.saveQuizzes(quizzes);
    final progressBox = _hiveService.progressBox;
    await progressBox.clear();
    await progressBox.putAll({for (final p in progress) p.id: p});
    final reviewerBox = _hiveService.reviewersBox;
    await reviewerBox.clear();
    await reviewerBox.putAll({for (final r in reviewers) r.topicId: r});
  }
}
