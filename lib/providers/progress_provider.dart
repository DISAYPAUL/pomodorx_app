import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_progress.dart';

class ProgressProvider extends ChangeNotifier {
  final Map<String, StudyProgress> _progressMap = {};
  bool _isLoading = false;

  Map<String, StudyProgress> get progressMap => _progressMap;
  bool get isLoading => _isLoading;

  List<StudyProgress> get progressList => _progressMap.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  int get totalMinutesAllTime {
    return _progressMap.values.fold(0, (sum, progress) => sum + progress.totalMinutes);
  }

  int get totalSessionsAllTime {
    return _progressMap.values.fold(0, (sum, progress) => sum + progress.sessionsCompleted);
  }

  int get currentStreak {
    final sortedDates = _progressMap.keys.toList()..sort((a, b) => b.compareTo(a));
    if (sortedDates.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    for (int i = 0; i < 365; i++) {
      final dateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
      if (_progressMap.containsKey(dateKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Allow one day gap for today if no sessions yet
        if (i == 0 && _isSameDay(checkDate, DateTime.now())) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    
    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    _progressMap.clear();
    
    for (final key in keys) {
      if (key.startsWith('progress_minutes_')) {
        final dateKey = key.replaceFirst('progress_minutes_', '');
        final minutes = prefs.getInt(key) ?? 0;
        final sessions = prefs.getInt('progress_sessions_$dateKey') ?? 0;
        
        final dateParts = dateKey.split('-');
        if (dateParts.length == 3) {
          final date = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          
          _progressMap[dateKey] = StudyProgress(
            date: date,
            totalMinutes: minutes,
            sessionsCompleted: sessions,
          );
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  StudyProgress? getProgressForDate(DateTime date) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    return _progressMap[dateKey];
  }

  // Get progress for a date range (for heatmap)
  List<StudyProgress> getProgressRange(DateTime start, DateTime end) {
    final result = <StudyProgress>[];
    DateTime current = start;
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final dateKey = '${current.year}-${current.month}-${current.day}';
      if (_progressMap.containsKey(dateKey)) {
        result.add(_progressMap[dateKey]!);
      }
      current = current.add(const Duration(days: 1));
    }
    
    return result;
  }

  // Get intensity level for heatmap (0-4)
  int getIntensityLevel(StudyProgress? progress) {
    if (progress == null || progress.totalMinutes == 0) return 0;
    
    // Scale based on minutes studied
    if (progress.totalMinutes < 25) return 1;
    if (progress.totalMinutes < 50) return 2;
    if (progress.totalMinutes < 100) return 3;
    return 4;
  }

  Color getIntensityColor(int level, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      switch (level) {
        case 0:
          return Colors.grey[800]!;
        case 1:
          return Colors.green[700]!;
        case 2:
          return Colors.green[600]!;
        case 3:
          return Colors.green[500]!;
        case 4:
          return Colors.green[400]!;
        default:
          return Colors.grey[800]!;
      }
    } else {
      switch (level) {
        case 0:
          return Colors.grey[200]!;
        case 1:
          return Colors.green[200]!;
        case 2:
          return Colors.green[300]!;
        case 3:
          return Colors.green[500]!;
        case 4:
          return Colors.green[700]!;
        default:
          return Colors.grey[200]!;
      }
    }
  }
}
