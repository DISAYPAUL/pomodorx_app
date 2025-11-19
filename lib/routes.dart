import 'package:flutter/material.dart';

import 'models/quiz.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/pomodoro_timer_screen.dart';
import 'screens/progress_tracker_screen.dart';
import 'screens/quiz_list_screen.dart';
import 'screens/quiz_play_screen.dart';
import 'screens/results_screen.dart';
import 'screens/reviewer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/topic_detail_screen.dart';
import 'screens/topics_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const pomodoro = '/pomodoro';
  static const progress = '/progress';
  static const topics = '/topics';
  static const topicDetail = '/topic-detail';
  static const reviewer = '/reviewer';
  static const quizList = '/quiz-list';
  static const quizPlay = '/quiz-play';
  static const results = '/results';
  static const settings = '/settings';
}

class TopicDetailArgs {
  TopicDetailArgs(this.topicId);
  final String topicId;
}

class ReviewerArgs {
  ReviewerArgs(this.topicId);
  final String topicId;
}

class QuizListArgs {
  QuizListArgs(this.topicId);
  final String topicId;
}

class QuizPlayArgs {
  QuizPlayArgs({required this.quiz});
  final Quiz quiz;
}

class ResultsArgs {
  ResultsArgs({this.quizId, this.topicId});
  final String? quizId;
  final String? topicId;
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case AppRoutes.pomodoro:
        return MaterialPageRoute(builder: (_) => const PomodoroTimerScreen());
      case AppRoutes.progress:
        return MaterialPageRoute(builder: (_) => const ProgressTrackerScreen());
      case AppRoutes.topics:
        return MaterialPageRoute(builder: (_) => const TopicsScreen());
      case AppRoutes.topicDetail:
        final args = settings.arguments as TopicDetailArgs;
        return MaterialPageRoute(
          builder: (_) => TopicDetailScreen(topicId: args.topicId),
        );
      case AppRoutes.reviewer:
        final args = settings.arguments as ReviewerArgs;
        return MaterialPageRoute(
          builder: (_) => ReviewerScreen(topicId: args.topicId),
        );
      case AppRoutes.quizList:
        final args = settings.arguments as QuizListArgs;
        return MaterialPageRoute(
          builder: (_) => QuizListScreen(topicId: args.topicId),
        );
      case AppRoutes.quizPlay:
        final args = settings.arguments as QuizPlayArgs;
        return MaterialPageRoute(
          builder: (_) => QuizPlayScreen(quiz: args.quiz),
        );
      case AppRoutes.results:
        final args = settings.arguments as ResultsArgs?;
        return MaterialPageRoute(
          builder: (_) =>
              ResultsScreen(quizId: args?.quizId, topicId: args?.topicId),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.splash:
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
