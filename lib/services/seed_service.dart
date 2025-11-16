import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../constants/app_constants.dart';
import '../models/models.dart';
import 'storage_service.dart';

class SeedService {
  SeedService(this._storage);

  final StorageService _storage;

  Future<void> seedIfEmpty() async {
    final existing = await _storage.getAllTopics();
    if (existing.isNotEmpty) return;

    final topics = <Topic>[];
    final quizzes = <Quiz>[];

    for (final file in AppConstants.seedFiles) {
      final content = await rootBundle.loadString(file);
      final Map<String, dynamic> jsonMap = json.decode(content)
          as Map<String, dynamic>;
      final topic = Topic.fromJson(jsonMap['topic'] as Map<String, dynamic>);
      topics.add(topic);
      final quizList = (jsonMap['quizzes'] as List<dynamic>)
          .map((raw) => Quiz.fromJson(raw as Map<String, dynamic>, topic.id));
      quizzes.addAll(quizList);
    }

    await _storage.saveTopics(topics);
    await _storage.saveQuizzes(quizzes);
  }
}
