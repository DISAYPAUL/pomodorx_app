import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';

class HiveService {
  HiveService._internal();

  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    Hive
      ..registerAdapter(TopicAdapter())
      ..registerAdapter(QuestionAdapter())
      ..registerAdapter(QuizAdapter())
      ..registerAdapter(UserProgressAdapter())
      ..registerAdapter(ProgressAnswerAdapter())
      ..registerAdapter(ReviewerCacheAdapter());
    await Future.wait([
      Hive.openBox<Topic>(AppConstants.topicsBox),
      Hive.openBox<Quiz>(AppConstants.quizzesBox),
      Hive.openBox<UserProgress>(AppConstants.progressBox),
      Hive.openBox<ReviewerCache>(AppConstants.reviewersBox),
    ]);
    _initialized = true;
  }

  Box<Topic> get topicsBox => Hive.box<Topic>(AppConstants.topicsBox);
  Box<Quiz> get quizzesBox => Hive.box<Quiz>(AppConstants.quizzesBox);
  Box<UserProgress> get progressBox => Hive.box<UserProgress>(AppConstants.progressBox);
  Box<ReviewerCache> get reviewersBox => Hive.box<ReviewerCache>(AppConstants.reviewersBox);

  Future<void> close() async {
    if (!_initialized) return;
    await Hive.close();
    _initialized = false;
  }
}
