import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:uuid/uuid.dart';

class TextFile implements JsonEncodable {
  final String id;
  final String name;
  final String rawText;
  final List<TextLine> textLines = [];
  final Set<TextCodingVersion> codingVersions = {};

  TextFile({
    required this.id,
    required this.name,
    required this.rawText,
  }) {
    final lines = rawText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    int offset = 0;
    for (int i = 0; i < lines.length; i++) {
      textLines.add(TextLine(
        index: i,
        offset: offset,
        text: lines[i],
      ));
      offset += lines[i].length;
    }
  }

  factory TextFile.withId({
    required String name,
    required String rawText,
  }) {
    final id = const Uuid().v4();
    return TextFile(id: id, name: name, rawText: rawText);
  }

  factory TextFile.fromJson(Map<String, dynamic> json, Iterable<Code> codes) {
    final id = json[TextFileJsonKeys.id];
    final name = json[TextFileJsonKeys.name];
    final text = json[TextFileJsonKeys.text];
    final file = TextFile(id: id, name: name, rawText: text);
    final codingVersions = json[TextFileJsonKeys.codingVersions] as List;
    file.codingVersions.addAll(codingVersions.map(
      (e) => TextCodingVersion.fromJson(e, file, codes),
    ));
    return file;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextFileJsonKeys.id: id,
      TextFileJsonKeys.name: name,
      TextFileJsonKeys.text: rawText,
      TextFileJsonKeys.codingVersions:
          codingVersions.map((e) => e.toJson()).toList(),
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
