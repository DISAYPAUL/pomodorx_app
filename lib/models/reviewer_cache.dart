import 'package:hive/hive.dart';

class ReviewerCache {
  ReviewerCache({
    required this.id,
    required this.topicId,
    required this.title,
    required this.body,
    this.ttsGenerated = false,
    required this.createdAt,
  });

  final String id;
  final String topicId;
  final String title;
  final String body;
  final bool ttsGenerated;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'title': title,
        'body': body,
        'ttsGenerated': ttsGenerated,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReviewerCache.fromJson(Map<String, dynamic> json) => ReviewerCache(
        id: json['id'] as String,
        topicId: json['topicId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        ttsGenerated: json['ttsGenerated'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ReviewerCacheAdapter extends TypeAdapter<ReviewerCache> {
  @override
  final int typeId = 5;

  @override
  ReviewerCache read(BinaryReader reader) {
    return ReviewerCache(
      id: reader.readString(),
      topicId: reader.readString(),
      title: reader.readString(),
      body: reader.readString(),
      ttsGenerated: reader.readBool(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, ReviewerCache obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.topicId);
    writer.writeString(obj.title);
    writer.writeString(obj.body);
    writer.writeBool(obj.ttsGenerated);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}
