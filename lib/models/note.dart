import 'package:uuid/uuid.dart';

import 'package:analysis_tool/models/json_encodable.dart';

class Note implements JsonEncodable {
  final String id;
  String text;

  Note({
    required this.id,
    required this.text,
  });

  factory Note.withId({required String text}) {
    final id = const Uuid().v4();
    return Note(id: id, text: text);
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final String id = json[NoteJsonKeys.id];
    final String text = json[NoteJsonKeys.text];
    return Note(id: id, text: text);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      NoteJsonKeys.id: id,
      NoteJsonKeys.text: text,
    };
  }

  @override
  bool operator ==(covariant Note other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class NoteJsonKeys {
  static const id = 'id';
  static const text = 'text';
}
