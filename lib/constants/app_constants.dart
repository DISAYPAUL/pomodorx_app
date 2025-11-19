class AppConstants {
  AppConstants._();

  static const appName = 'PomodoRx';
  static const appVersion = '0.1.0';

  static const topicsBox = 'topics';
  static const quizzesBox = 'quizzes';
  static const progressBox = 'progress';
  static const reviewersBox = 'reviewers';

  static const lastOpenedTopicKey = 'lastOpenedTopicId';
  static const themeModeKey = 'themeMode';
  static const ttsEnabledKey = 'ttsEnabled';
  static const notificationsEnabledKey = 'notificationsEnabled';

  static const seedFiles = [
    'assets/data/anatomy_quiz.json',
    'assets/data/pharmacology_quiz.json',
    'assets/data/nursing_quizzes.json',
    'assets/data/nclex_practice_bank.json',
  ];

  static const nursingTopicIds = {
    'topic-pharmacology',
    'topic-pharm',
    'topic-med-surg',
    'topic-pediatrics',
    'topic-maternal',
    'topic-mental',
    'topic-fundamentals',
  };
}
