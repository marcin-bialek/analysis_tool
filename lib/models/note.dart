import 'package:analysis_tool/models/observable.dart';
import 'package:uuid/uuid.dart';

import 'package:analysis_tool/models/json_encodable.dart';

class Note implements JsonEncodable {
  final String id;
  final Observable<String> title;
  final Observable<String> text;
  final Map<String, Set<int>> codingLines = {};

  Note({
    required this.id,
    required String title,
    required String text,
  })  : title = Observable(title),
        text = Observable(text);

  factory Note.withId({required String title, required String text}) {
    final id = const Uuid().v4();
    return Note(id: id, title: title, text: text);
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final String id = json[NoteJsonKeys.id];
    final String title = json[NoteJsonKeys.title];
    final String text = json[NoteJsonKeys.text];
    final Map<String, dynamic> codingLines = json[NoteJsonKeys.codingLines];
    final note = Note(id: id, title: title, text: text);
    note.codingLines.addAll(codingLines.map((id, value) {
      final indices = value as List<dynamic>;
      return MapEntry(id, indices.map((e) => e as int).toSet());
    }));
    return note;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      NoteJsonKeys.id: id,
      NoteJsonKeys.title: title.value,
      NoteJsonKeys.text: text.value,
      NoteJsonKeys.codingLines: codingLines.map((k, v) {
        return MapEntry(k, v.toList());
      }),
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
  static const title = 'title';
  static const text = 'text';
  static const codingLines = 'codingLines';
}
