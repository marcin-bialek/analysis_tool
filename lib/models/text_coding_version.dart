import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/text_coding.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:uuid/uuid.dart';

class TextCodingVersion implements JsonEncodable {
  final String id;
  final String name;
  final TextFile file;
  final Set<TextCoding> codings = {};

  TextCodingVersion({
    required this.id,
    required this.name,
    required this.file,
  });

  factory TextCodingVersion.withId({
    required String name,
    required TextFile file,
  }) {
    final id = const Uuid().v4();
    return TextCodingVersion(id: id, name: name, file: file);
  }

  factory TextCodingVersion.fromJson(
    Map<String, dynamic> json,
    Iterable<TextFile> files,
    Iterable<Code> codes,
  ) {
    final id = json[TextCodingVersionJsonKeys.id];
    final name = json[TextCodingVersionJsonKeys.name];
    final fileId = json[TextCodingVersionJsonKeys.fileId];
    final file = files.firstWhere((e) => e.id == fileId);
    final version = TextCodingVersion(id: id, name: name, file: file);
    final codings = json[TextCodingVersionJsonKeys.codings] as List;
    version.codings.addAll(codings.map((e) => TextCoding.fromJson(e, codes)));
    return version;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextCodingVersionJsonKeys.id: id,
      TextCodingVersionJsonKeys.name: name,
      TextCodingVersionJsonKeys.fileId: file.id,
      TextCodingVersionJsonKeys.codings:
          codings.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(covariant TextCodingVersion other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TextCodingVersionJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const fileId = 'fileId';
  static const codings = 'codings';
}
