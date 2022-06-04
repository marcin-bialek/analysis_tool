import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/json_encodable.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/models/observable.dart';
import 'package:qdamono/models/text_coding_version.dart';
import 'package:uuid/uuid.dart';

class TextFile implements JsonEncodable {
  final String id;
  final Observable<String> name;
  final Observable<String> rawText;
  final textLines = Observable<List<TextLine>>([]);
  final codingVersions = Observable<Set<TextCodingVersion>>({});

  TextFile({
    required this.id,
    required String name,
    required String rawText,
  })  : name = Observable(name),
        rawText = Observable(rawText) {
    makeTextLines();
  }

  factory TextFile.withId({
    required String name,
    required String rawText,
  }) {
    final id = const Uuid().v4();
    return TextFile(id: id, name: name, rawText: rawText);
  }

  factory TextFile.fromJson(
    Map<String, dynamic> json,
    Iterable<Code> codes,
    Iterable<Note> notes,
  ) {
    final id = json[TextFileJsonKeys.id];
    final name = json[TextFileJsonKeys.name];
    final text = json[TextFileJsonKeys.text];
    final file = TextFile(id: id, name: name, rawText: text);
    final codingVersions = json[TextFileJsonKeys.codingVersions] as List;
    file.codingVersions.value.addAll(codingVersions.map(
      (e) => TextCodingVersion.fromJson(e, file, codes, notes),
    ));
    return file;
  }

  void makeTextLines() {
    final lines = rawText.value
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    textLines.value.clear();
    int offset = 0;
    for (int i = 0; i < lines.length; i++) {
      textLines.value.add(TextLine(
        index: i,
        offset: offset,
        text: lines[i],
      ));
      offset += lines[i].length;
    }
    textLines.notify();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextFileJsonKeys.id: id,
      TextFileJsonKeys.name: name.value,
      TextFileJsonKeys.text: rawText.value,
      TextFileJsonKeys.codingVersions:
          codingVersions.value.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(covariant TextFile other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TextFile(id: $id, name: $name)';
  }
}

class TextFileJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const text = 'text';
  static const codingVersions = 'codingVersions';
}

class TextLine {
  final int index;
  final int offset;
  final String text;
  int get endOffset => offset + text.length;

  TextLine({
    required this.index,
    required this.offset,
    required this.text,
  });
}
