import 'package:analysis_tool/models/json_encodable.dart';
import 'package:uuid/uuid.dart';

class TextFile implements JsonEncodable {
  final String id;
  final String name;
  final List<String> textLines;

  const TextFile({
    required this.id,
    required this.name,
    required this.textLines,
  });

  factory TextFile.withId({
    required String name,
    required List<String> textLines,
  }) {
    final id = const Uuid().v4();
    return TextFile(id: id, name: name, textLines: textLines);
  }

  factory TextFile.fromJson(Map<String, dynamic> json) {
    final id = json[TextFileJsonKeys.id];
    final name = json[TextFileJsonKeys.name];
    final textLines = json[TextFileJsonKeys.textLines];
    return TextFile(id: id, name: name, textLines: textLines);
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
