import 'package:hive/hive.dart';

class Topic {
  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.slug,
    required this.createdAt,
    this.detailedDescription,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final String slug;
  final DateTime createdAt;
  final String? detailedDescription;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      slug: json['slug'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      detailedDescription: json['detailedDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'slug': slug,
        'createdAt': createdAt.toIso8601String(),
        if (detailedDescription != null) 'detailedDescription': detailedDescription,
      };
}

class TopicAdapter extends TypeAdapter<Topic> {
  @override
  final int typeId = 0;

  @override
  Topic read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final description = reader.readString();
    final icon = reader.readString();
    final slug = reader.readString();
    final createdAt = DateTime.parse(reader.readString());
    // New versions of Topic write an additional boolean + string for
    // `detailedDescription`. Older installs won't have this value saved;
    // reading it directly will throw. Read it safely and fall back if
    // the reader runs out of bytes.
    String? detailedDescription;
    try {
      final hasDetailed = reader.readBool();
      detailedDescription = hasDetailed ? reader.readString() : null;
    } catch (e) {
      // Older saved objects don't include the detailed description.
      detailedDescription = null;
    }
    return Topic(
      id: id,
      name: name,
      description: description,
      icon: icon,
      slug: slug,
      createdAt: createdAt,
      detailedDescription: detailedDescription,
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
    // Write the presence boolean so new readers can pick up the extra
    // string. Older readers won't be able to read these values, but we
    // keep the order consistent for newer readers.
    writer.writeBool(obj.detailedDescription != null);
    if (obj.detailedDescription != null) {
      writer.writeString(obj.detailedDescription!);
    }
  }
}
