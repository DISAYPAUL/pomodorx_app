import 'package:hive/hive.dart';

class ProgressAnswer {
  ProgressAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.correct,
  });

  final String questionId;
  final int selectedIndex;
  final bool correct;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedIndex': selectedIndex,
        'correct': correct,
      };

  factory ProgressAnswer.fromJson(Map<String, dynamic> json) => ProgressAnswer(
        questionId: json['questionId'] as String,
        selectedIndex: json['selectedIndex'] as int,
        correct: json['correct'] as bool,
      );
}

class UserProgress {
  UserProgress({
    required this.id,
    required this.quizId,
    required this.score,
    required this.maxScore,
    required this.answers,
    required this.attemptedAt,
  });

  final String id;
  final String quizId;
  final int score;
  final int maxScore;
  final List<ProgressAnswer> answers;
  final DateTime attemptedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'quizId': quizId,
        'score': score,
        'maxScore': maxScore,
        'answers': answers.map((a) => a.toJson()).toList(),
        'attemptedAt': attemptedAt.toIso8601String(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        id: json['id'] as String,
        quizId: json['quizId'] as String,
        score: json['score'] as int,
        maxScore: json['maxScore'] as int,
        answers: (json['answers'] as List<dynamic>)
            .map((e) => ProgressAnswer.fromJson(e as Map<String, dynamic>))
            .toList(),
        attemptedAt: DateTime.parse(json['attemptedAt'] as String),
      );
}

class ProgressAnswerAdapter extends TypeAdapter<ProgressAnswer> {
  @override
  final int typeId = 4;

  @override
  ProgressAnswer read(BinaryReader reader) {
    return ProgressAnswer(
      questionId: reader.readString(),
      selectedIndex: reader.readInt(),
      correct: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgressAnswer obj) {
    writer.writeString(obj.questionId);
    writer.writeInt(obj.selectedIndex);
    writer.writeBool(obj.correct);
  }
}

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 3;

  @override
  UserProgress read(BinaryReader reader) {
    return UserProgress(
      id: reader.readString(),
      quizId: reader.readString(),
      score: reader.readInt(),
      maxScore: reader.readInt(),
      answers: reader.readList().cast<ProgressAnswer>(),
      attemptedAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.quizId);
    writer.writeInt(obj.score);
    writer.writeInt(obj.maxScore);
    writer.writeList(obj.answers);
    writer.writeString(obj.attemptedAt.toIso8601String());
  }
}
