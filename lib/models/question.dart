import 'package:hive/hive.dart';

class Question {
  Question({
    required this.id,
    required this.quizId,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.type,
  });

  final String id;
  final String quizId;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String type;

  factory Question.fromJson(Map<String, dynamic> json, String quizId) {
    return Question(
      id: json['id'] as String,
      quizId: quizId,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String?,
      type: json['type'] as String? ?? 'mcq',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quizId': quizId,
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'type': type,
      };
}

class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 1;

  @override
  Question read(BinaryReader reader) {
    final id = reader.readString();
    final quizId = reader.readString();
    final text = reader.readString();
    final options = reader.readList().cast<String>();
    final correctIndex = reader.readInt();
    final explanation = reader.readBool() ? reader.readString() : null;
    final type = reader.readString();
    return Question(
      id: id,
      quizId: quizId,
      text: text,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      type: type,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.quizId);
    writer.writeString(obj.text);
    writer.writeList(obj.options);
    writer.writeInt(obj.correctIndex);
    if (obj.explanation != null) {
      writer.writeBool(true);
      writer.writeString(obj.explanation!);
    } else {
      writer.writeBool(false);
    }
    writer.writeString(obj.type);
  }
}
