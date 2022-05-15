import 'package:analysis_tool/models/json_encodable.dart';
import 'package:uuid/uuid.dart';

class TextFile implements JsonEncodable {
  final String id;
  final String name;
  final List<String> textLines = [];

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

  factory TextFile.fromJson(Map<String, dynamic> json) {
    final id = json[TextFileJsonKeys.id];
    final name = json[TextFileJsonKeys.name];
    final file = TextFile(id: id, name: name);
    final textLines = json[TextFileJsonKeys.textLines] as List<String>;
    file.textLines.addAll(textLines);
    return file;
  }

  factory TextFile.fromText(String name, String text) {
    final file = TextFile.withId(name: name);
    file.textLines.addAll(text.split('\n').map((e) => e.trim()));
    return file;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextFileJsonKeys.id: id,
      TextFileJsonKeys.name: name,
      TextFileJsonKeys.textLines: textLines,
    };
  }

  @override
  bool operator ==(covariant TextFile other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TextFileJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const textLines = 'textLines';
}
