import 'dart:async';

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
  List<TextCodingLine>? _codingLines;
  late final StreamController<List<TextCodingLine>>
      _codingLinesStreamController;

  Stream<List<TextCodingLine>> get codingLinesStream =>
      _codingLinesStreamController.stream;

  TextCodingVersion({
    required this.id,
    required this.name,
    required this.file,
  }) {
    _codingLinesStreamController = StreamController.broadcast(
      onListen: () async {
        final codingLines = await _getCodingLines();
        _codingLinesStreamController.add(codingLines);
      },
    );
  }

  factory TextCodingVersion.withId({
    required String name,
    required TextFile file,
  }) {
    final id = const Uuid().v4();
    return TextCodingVersion(id: id, name: name, file: file);
  }

  factory TextCodingVersion.fromJson(
    Map<String, dynamic> json,
    TextFile file,
    Iterable<Code> codes,
  ) {
    final id = json[TextCodingVersionJsonKeys.id];
    final name = json[TextCodingVersionJsonKeys.name];
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

  Future<List<TextCodingLine>> _getCodingLines() async {
    if (_codingLines != null) {
      return _codingLines!;
    }
    final List<TextCodingLine> codingLines = [];
    for (final line in file.textLines) {
      final codingLine = TextCodingLine(index: line.index);
      for (final coding in codings) {
        if (line.offset <= coding.start && coding.start < line.endOffset) {
          codingLine.codings.add(coding);
        } else if (line.offset <= coding.end && coding.end < line.endOffset) {
          codingLine.codings.add(coding);
        }
      }
      codingLines.add(codingLine);
    }
    _codingLines = codingLines;
    return codingLines;
  }

  void addCoding(TextCodingLine line, Code code, int offset, int length) {
    final coding = TextCoding(code: code, start: offset, length: length);
    line.codings.add(coding);
    _codingLinesStreamController.add(_codingLines!);
  }
}

class TextCodingVersionJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const codings = 'codings';
}

class TextCodingLine {
  final int index;
  final Set<TextCoding> codings = {};

  TextCodingLine({required this.index});
}
