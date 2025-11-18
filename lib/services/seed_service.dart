import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../constants/app_constants.dart';
import '../models/models.dart';
import 'storage_service.dart';

class _SeedBundle {
  const _SeedBundle({required this.topics, required this.quizzes});

  final List<Topic> topics;
  final List<Quiz> quizzes;
}

class SeedService {
  SeedService(this._storage);

  final StorageService _storage;

  Future<void> seedIfEmpty() async {
    final existingTopics = await _storage.getAllTopics();
    final bundle = await _loadSeedBundle();
    if (bundle.topics.isEmpty) return;

    final existingIds = existingTopics.map((topic) => topic.id).toSet();
    final missingSeedTopic = bundle.topics
        .map((topic) => topic.id)
        .any((id) => !existingIds.contains(id));

    if (existingTopics.isEmpty || missingSeedTopic) {
      final mergedTopics = {
        for (final topic in existingTopics) topic.id: topic,
      };
      for (final topic in bundle.topics) {
        mergedTopics[topic.id] = topic;
      }
      await _storage.saveTopics(mergedTopics.values.toList());
      await _storage.saveQuizzes(bundle.quizzes);
    } else {
      // Upsert quizzes in case the topic already exists but updated content
      await _storage.saveQuizzes(bundle.quizzes);
    }
  }

  Future<_SeedBundle> _loadSeedBundle() async {
    final topics = <Topic>[];
    final quizzes = <Quiz>[];

    for (final file in AppConstants.seedFiles) {
      final content = await rootBundle.loadString(file);
      final Map<String, dynamic> jsonMap =
          json.decode(content) as Map<String, dynamic>;

      if (jsonMap.containsKey('topics')) {
        final List<dynamic> topicEntries = jsonMap['topics'] as List<dynamic>;
        for (final rawEntry in topicEntries) {
          final entry = rawEntry as Map<String, dynamic>;
          final topicJson = entry['topic'] as Map<String, dynamic>;
          final topic = Topic.fromJson(topicJson);
          topics.add(topic);
          final quizList = (entry['quizzes'] as List<dynamic>)
              .map((raw) =>
                  Quiz.fromJson(raw as Map<String, dynamic>, topic.id));
          quizzes.addAll(quizList);
        }
      } else {
        final topic = Topic.fromJson(jsonMap['topic'] as Map<String, dynamic>);
        topics.add(topic);
        final quizList = (jsonMap['quizzes'] as List<dynamic>)
            .map((raw) => Quiz.fromJson(raw as Map<String, dynamic>, topic.id));
        quizzes.addAll(quizList);
      }
    }

    return _SeedBundle(topics: topics, quizzes: quizzes);
  }
}
