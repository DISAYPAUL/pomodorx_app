import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';

import '../models/pomodoro_session.dart';
import '../constants/app_constants.dart';

class PomodoroProvider extends ChangeNotifier {
  PomodoroSettings _settings = const PomodoroSettings();
  TimerStatus _status = TimerStatus.initial;
  SessionType _currentSessionType = SessionType.work;
  int _remainingSeconds = 25 * 60;
  int _completedWorkSessions = 0;
  Timer? _timer;
  DateTime? _sessionStartTime;
  bool _isReverseMode = false;
  int _elapsedSeconds = 0;
  static const List<int> _allowedWorkDurations = [25, 45];

  PomodoroSettings get settings => _settings;
  TimerStatus get status => _status;
  SessionType get currentSessionType => _currentSessionType;
  int get remainingSeconds => _remainingSeconds;
  int get completedWorkSessions => _completedWorkSessions;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isCompleted => _status == TimerStatus.completed;
  bool get isReverseMode => _isReverseMode;
  int get elapsedSeconds => _elapsedSeconds;

  int get currentSessionDuration {
    switch (_currentSessionType) {
      case SessionType.work:
        return _settings.workDuration * 60;
      case SessionType.shortBreak:
        return _settings.shortBreakDuration * 60;
      case SessionType.longBreak:
        return _settings.longBreakDuration * 60;
    }
  }

  // Returns completed fraction (0.0 - 1.0) used by the circular progress painter.
  double get progress {
    if (_isReverseMode) {
      return 0.0; // No progress circle in reverse mode
    }
    if (currentSessionDuration == 0) return 0;
    final completed = (currentSessionDuration - _remainingSeconds);
    return (completed / currentSessionDuration).clamp(0.0, 1.0);
  }

  String get formattedTime {
    if (_isReverseMode) {
      final minutes = _elapsedSeconds ~/ 60;
      final seconds = _elapsedSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionLabel {
    switch (_currentSessionType) {
      case SessionType.work:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('pomodoro_settings');
    if (settingsJson != null) {
      _settings = PomodoroSettings.fromJson(jsonDecode(settingsJson));
      _resetTimer();
      notifyListeners();
    }

    final completedSessions = prefs.getInt('completed_work_sessions') ?? 0;
    _completedWorkSessions = completedSessions;
    notifyListeners();
  }

  Future<void> updateSettings(PomodoroSettings newSettings) async {
    _settings = newSettings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pomodoro_settings', jsonEncode(_settings.toJson()));
    _resetTimer();
    notifyListeners();
  }

  void _persistSettings() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pomodoro_settings', jsonEncode(_settings.toJson()));
    });
  }

  void start() {
    if (_status == TimerStatus.initial || _status == TimerStatus.completed) {
      _sessionStartTime = DateTime.now();
      if (_isReverseMode) {
        _elapsedSeconds = 0;
      }
    }

    _status = TimerStatus.running;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isReverseMode) {
        _elapsedSeconds++;
        notifyListeners();
      } else {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          _onSessionComplete();
        }
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _status = TimerStatus.paused;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _status = TimerStatus.initial;
    _resetTimer();
    _sessionStartTime = null;
    if (_isReverseMode) {
      _elapsedSeconds = 0;
    }
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    _onSessionComplete();
  }

  void _resetTimer() {
    _remainingSeconds = currentSessionDuration;
  }

  Future<void> _onSessionComplete() async {
    _timer?.cancel();
    _status = TimerStatus.completed;

    // Record completed work session
    if (_currentSessionType == SessionType.work) {
      _completedWorkSessions++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('completed_work_sessions', _completedWorkSessions);
      
      // Save to progress tracking
      await _saveProgress();
    }

    notifyListeners();

    // Fire notification / sound
    try {
      final notif = NotificationService();
      final tts = TtsService();

      final prefs = await SharedPreferences.getInstance();
      final notificationsAllowed = prefs.getBool(AppConstants.notificationsEnabledKey) ?? true;
      final ttsAllowed = prefs.getBool(AppConstants.ttsEnabledKey) ?? true;

      if (_currentSessionType == SessionType.work) {
        // Work finished -> notify about break starting
        final nextIsLong = (_settings.workDuration == 45 && (_settings.autoStartBreaks || _settings.autoStartPomodoros)) ||
            (_completedWorkSessions % _settings.sessionsUntilLongBreak == 0);
        final breakLabel = nextIsLong ? 'Long break' : 'Short break';
        if (notificationsAllowed) {
          await notif.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'Work session finished',
          body: 'Time for a $breakLabel',
          );
        }
        if (ttsAllowed) {
          await tts.speak('Work session finished. Time for a $breakLabel.');
        }
      } else {
        // Break finished
        if (notificationsAllowed) {
          await notif.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'Break finished',
          body: 'Back to work!',
          );
        }
        if (ttsAllowed) {
          await tts.speak('Break finished. Back to work.');
        }
      }
    } catch (_) {}

    // Auto-start next session if enabled
    await Future.delayed(const Duration(seconds: 1));
    _moveToNextSession();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    
    final existingMinutes = prefs.getInt('progress_minutes_$dateKey') ?? 0;
    final existingSessions = prefs.getInt('progress_sessions_$dateKey') ?? 0;
    
    await prefs.setInt('progress_minutes_$dateKey', existingMinutes + _settings.workDuration);
    await prefs.setInt('progress_sessions_$dateKey', existingSessions + 1);
  }

  void _moveToNextSession() {
    if (_currentSessionType == SessionType.work) {
      // After work session, decide on break type.
      // If user picked a longer work duration (45 minutes) and auto-start sessions
      // is enabled, prefer starting a long break immediately (15 min) to match
      // extended focus sessions.
      if (_settings.workDuration == 45 && (_settings.autoStartBreaks || _settings.autoStartPomodoros)) {
        _currentSessionType = SessionType.longBreak;
      } else if (_completedWorkSessions % _settings.sessionsUntilLongBreak == 0) {
        _currentSessionType = SessionType.longBreak;
      } else {
        _currentSessionType = SessionType.shortBreak;
      }
      
      _resetTimer();
      _status = TimerStatus.initial;
      notifyListeners();

      // Auto-start break if enabled
      if (_settings.autoStartBreaks) {
        Future.delayed(const Duration(milliseconds: 500), () => start());
      }
    } else {
      // After break, go back to work
      _currentSessionType = SessionType.work;
      _resetTimer();
      _status = TimerStatus.initial;
      notifyListeners();

      // Auto-start work session if enabled
      if (_settings.autoStartPomodoros) {
        Future.delayed(const Duration(milliseconds: 500), () => start());
      }
    }
  }

  void setAutoStartBreaks(bool enabled) {
    _settings = _settings.copyWith(autoStartBreaks: enabled);
    _persistSettings();
    notifyListeners();
  }

  void setAutoStartPomodoros(bool enabled) {
    _settings = _settings.copyWith(autoStartPomodoros: enabled);
    _persistSettings();
    notifyListeners();
  }

  void setWorkDurationPreset(int minutes) {
    if (!_allowedWorkDurations.contains(minutes)) return;
    if (_settings.workDuration == minutes) return;
    _settings = _settings.copyWith(workDuration: minutes);
    _persistSettings();
    reset();
  }

  void startManualBreak(SessionType breakType) {
    if (_settings.autoStartBreaks) return;
    if (breakType != SessionType.shortBreak && breakType != SessionType.longBreak) return;
    _currentSessionType = breakType;
    _resetTimer();
    _status = TimerStatus.initial;
    notifyListeners();
    start();
  }

  void toggleTimerMode() {
    _isReverseMode = !_isReverseMode;
    reset();
    notifyListeners();
  }

  void stopReverseTimer() {
    if (_isReverseMode && _status == TimerStatus.running) {
      _timer?.cancel();
      _status = TimerStatus.completed;
      _completedWorkSessions++;
      SharedPreferences.getInstance().then((prefs) async {
        await prefs.setInt('completed_work_sessions', _completedWorkSessions);
        await _saveProgress();
      });
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
