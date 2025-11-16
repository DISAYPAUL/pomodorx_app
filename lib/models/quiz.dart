import 'package:hive/hive.dart';

import 'question.dart';

class Quiz {
  Quiz({
    required this.id,
    required this.topicId,
    required this.title,
    this.durationMinutes,
    required this.questions,
    required this.createdAt,
    this.isOffline = true,
  });

  final String id;
  final String topicId;
  final String title;
  final int? durationMinutes;
  final List<Question> questions;
  final DateTime createdAt;
  final bool isOffline;

  factory Quiz.fromJson(Map<String, dynamic> json, String topicId) {
    final quizId = json['id'] as String;
    return Quiz(
      id: quizId,
      topicId: topicId,
      title: json['title'] as String,
      durationMinutes: json['durationMinutes'] as int?,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>, quizId))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOffline: json['isOffline'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'title': title,
        'durationMinutes': durationMinutes,
        'questions': questions.map((q) => q.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'isOffline': isOffline,
      };
}

class QuizAdapter extends TypeAdapter<Quiz> {
  @override
  final int typeId = 2;

  @override
  Quiz read(BinaryReader reader) {
    final id = reader.readString();
    final topicId = reader.readString();
    final title = reader.readString();
    final hasDuration = reader.readBool();
    final durationMinutes = hasDuration ? reader.readInt() : null;
    final questions = reader.readList().cast<Question>();
    final createdAt = DateTime.parse(reader.readString());
    final isOffline = reader.readBool();
    return Quiz(
      id: id,
      topicId: topicId,
      title: title,
      durationMinutes: durationMinutes,
      questions: questions,
      createdAt: createdAt,
      isOffline: isOffline,
    );
  }

  @override
  void write(BinaryWriter writer, Quiz obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.topicId);
    writer.writeString(obj.title);
    if (obj.durationMinutes != null) {
      writer.writeBool(true);
      writer.writeInt(obj.durationMinutes!);
    } else {
      writer.writeBool(false);
    }
    writer.writeList(obj.questions);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.isOffline);
  }
}
