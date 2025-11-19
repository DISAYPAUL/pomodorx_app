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
  bool _isSpeaking = false;

  ReviewerCache? get current => _current;
  bool get isLoading => _loading;
  bool get isSpeaking => _isSpeaking;

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
    _isSpeaking = true;
    notifyListeners();
    try {
      final script = _sanitizeForSpeech(_current!.body);
      await _ttsService.speak(script);
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
    if (_isSpeaking) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  String _buildSummary(Topic topic, List<Quiz> quizzes) {
    final buffer = StringBuffer()
      ..writeln('${topic.name} Study Module')
      ..writeln('-' * (topic.name.length + 13));

    final trimmedDescription = topic.description.trim();
    if (trimmedDescription.isNotEmpty) {
      buffer
        ..writeln('Module overview: $trimmedDescription')
        ..writeln('');
    }

    final questionPool = _collectUniqueQuestions(quizzes);
    if (questionPool.isEmpty) {
      buffer.writeln(
        'No questions available yet. Run a quiz to unlock this module.',
      );
      return buffer.toString();
    }

    final learningOutcomes = questionPool.take(3).toList();
    final playbookItems = questionPool.length > 3
        ? questionPool.sublist(3)
        : questionPool;
    final condensedPlaybook = playbookItems.take(4).toList();
    final saundersNotes = _collectSaundersNotes(questionPool);

    buffer.writeln('Learning outcomes:');
    if (learningOutcomes.isEmpty) {
      buffer.writeln('1. Connect question cues to the first safety move.');
    } else {
      for (var i = 0; i < learningOutcomes.length; i++) {
        final focus = _moduleOutcome(learningOutcomes[i]);
        buffer.writeln('${i + 1}. $focus');
      }
    }

    buffer
      ..writeln('')
      ..writeln('Clinical playbook:');
    for (final question in condensedPlaybook) {
      final cue = _moduleCue(question);
      final answer = _safeAnswer(question);
      final rationale = _professorNote(question);
      buffer
        ..writeln('• Cue: $cue')
        ..writeln('  Answer anchor: $answer')
        ..writeln('  Rationale: $rationale');
    }

    buffer
      ..writeln('')
      ..writeln('Self-check drills:');
    for (final question in questionPool.take(3)) {
      buffer.writeln('- Ask yourself: ${_questionPrompt(question)}');
    }

    buffer
      ..writeln('')
      ..writeln('Saunders reference focus:');
    if (saundersNotes.isEmpty) {
      buffer.writeln(
        '- Pair every cue with the Saunders priority reminder for the topic.',
      );
    } else {
      for (final note in saundersNotes.take(6)) {
        buffer.writeln('- $note');
      }
    }

    buffer
      ..writeln('')
      ..writeln('Topic walkthrough:');
    for (final question in questionPool.take(5)) {
      final prompt = _questionPrompt(question);
      final saunders =
          _questionSaundersCue(question) ??
          'Link the assessment cue to the matching safety intervention.';
      buffer
        ..writeln('• Scenario: $prompt')
        ..writeln('  Saunders says: $saunders')
        ..writeln('  RN move: ${_safeAnswer(question)}')
        ..writeln('  Rationale: ${_professorNote(question)}');
    }

    buffer
      ..writeln('')
      ..writeln('Study coach tips:')
      ..writeln('- Teach the cue aloud, then link it to the why.')
      ..writeln(
        '- Pair each answer with the vital sign, lab, or symptom it protects.',
      )
      ..writeln(
        '- Close the loop by writing one sentence on how you would explain this to a patient.',
      );

    return buffer.toString().trim();
  }

  String _safeAnswer(Question question) {
    if (question.options.isEmpty) {
      return 'Review the safest nurse-led response.';
    }
    final index = question.correctIndex;
    if (index < 0 || index >= question.options.length) {
      return 'Match the cue to the intervention that prevents harm.';
    }
    return question.options[index];
  }

  String _professorNote(Question question) {
    final explanation = question.explanation?.trim();
    if (explanation != null && explanation.isNotEmpty) {
      return explanation;
    }
    return 'State the physiologic change, the risk it creates, and how this answer resolves it.';
  }

  String _sanitizeForSpeech(String text) {
    var sanitized = text
        .replaceAll('•', ' bullet ')
        .replaceAll('–', ' ')
        .replaceAll('—', ' ')
        .replaceAll('•', ' bullet ');
    sanitized = sanitized.replaceAll(RegExp(r'\s+-\s+'), ' ');
    sanitized = sanitized.replaceAll(RegExp(r'\s+•\s+'), ' ');
    sanitized = sanitized.replaceAll(RegExp(r'\s{2,}'), ' ');
    return sanitized.trim();
  }

  List<Question> _collectUniqueQuestions(List<Quiz> quizzes) {
    final unique = <String>{};
    final results = <Question>[];
    for (final quiz in quizzes) {
      for (final question in quiz.questions) {
        if (unique.add(question.id)) {
          results.add(question);
        }
      }
    }
    return results;
  }

  String _moduleOutcome(Question question) {
    final cue = _moduleCue(question);
    return 'Apply ${cue.toLowerCase()} to protect the patient response.';
  }

  String _moduleCue(Question question) {
    final text = question.text.trim();
    final parts = text.split('Saunders reminder:');
    var cue = parts.length > 1 ? parts.last : text;
    cue = cue.trim();
    final idx = cue.indexOf('?');
    if (idx != -1) {
      cue = cue.substring(0, idx).trim();
    }
    if (cue.isEmpty) {
      return 'the priority cue in this topic';
    }
    if (!cue.endsWith('.')) {
      cue = '$cue.';
    }
    return cue;
  }

  String _questionPrompt(Question question) {
    final text = question.text.trim();
    final idx = text.lastIndexOf('?');
    if (idx != -1) {
      return text.substring(0, idx + 1).trim();
    }
    return 'What is the safest next action for this cue?';
  }

  List<String> _collectSaundersNotes(List<Question> questions) {
    final notes = <String>{};
    for (final question in questions) {
      final cue = _questionSaundersCue(question);
      if (cue != null && cue.isNotEmpty) {
        notes.add(cue);
      }
    }
    return notes.toList();
  }

  String? _questionSaundersCue(Question question) {
    final text = question.text;
    final cueMatch = RegExp(
      r'Saunders cue:\s*([^\.]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (cueMatch != null) {
      return cueMatch.group(1)?.trim();
    }
    final reminderMatch = RegExp(
      r'Saunders reminder:\s*([^\.]+)',
      caseSensitive: false,
    ).firstMatch(text);
    return reminderMatch?.group(1)?.trim();
  }
}
