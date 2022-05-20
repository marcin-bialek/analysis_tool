import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:uuid/uuid.dart';

class TextFile implements JsonEncodable {
  final String id;
  final String name;
  final List<String> textLines = [];
  final Set<TextCodingVersion> codingVersions = {};

  TextFile({
    required this.id,
    required this.name,
  });

  factory TextFile.withId({
    required String name,
  }) {
    final id = const Uuid().v4();
    return TextFile(id: id, name: name);
  }

  factory TextFile.fromJson(Map<String, dynamic> json, Iterable<Code> codes) {
    final id = json[TextFileJsonKeys.id];
    final name = json[TextFileJsonKeys.name];
    final file = TextFile(id: id, name: name);
    final textLines = json[TextFileJsonKeys.textLines] as List;
    file.textLines.addAll(textLines.map((e) => e.toString()));
    final codingVersions = json[TextFileJsonKeys.codingVersions] as List;
    file.codingVersions.addAll(codingVersions.map(
      (e) => TextCodingVersion.fromJson(e, file, codes),
    ));
    return file;
  }

  factory TextFile.fromText(String name, String text) {
    final file = TextFile.withId(name: name);
    file.textLines.addAll(
        text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty));
    return file;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextFileJsonKeys.id: id,
      TextFileJsonKeys.name: name,
      TextFileJsonKeys.textLines: textLines,
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
  static const textLines = 'textLines';
  static const codingVersions = 'codingVersions';
}
