import 'package:hive/hive.dart';

class Topic {
  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.slug,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final String slug;
  final DateTime createdAt;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      slug: json['slug'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'slug': slug,
        'createdAt': createdAt.toIso8601String(),
      };
}

class TopicAdapter extends TypeAdapter<Topic> {
  @override
  final int typeId = 0;

  @override
  Topic read(BinaryReader reader) {
    return Topic(
      id: reader.readString(),
      name: reader.readString(),
      description: reader.readString(),
      icon: reader.readString(),
      slug: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Topic obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeString(obj.icon);
    writer.writeString(obj.slug);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}
