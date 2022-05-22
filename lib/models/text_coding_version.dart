import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/observable.dart';
import 'package:analysis_tool/models/text_coding.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:uuid/uuid.dart';

class TextCodingVersion implements JsonEncodable {
  final String id;
  final TextFile file;
  final Observable<String> name;
  final codings = Observable<Set<TextCoding>>({});
  Observable<List<TextCodingLine>>? _codingLines;
  Observable<List<TextCodingLine>> get codingLines {
    if (_codingLines == null) {
      _codingLines = Observable<List<TextCodingLine>>([]);
      _makeCodingLines();
    }
    return _codingLines!;
  }

  TextCodingVersion({
    required this.id,
    required this.file,
    required String name,
  }) : name = Observable(name);

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
    version.codings.value
        .addAll(codings.map((e) => TextCoding.fromJson(e, codes)));
    return version;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextCodingVersionJsonKeys.id: id,
      TextCodingVersionJsonKeys.name: name.value,
      TextCodingVersionJsonKeys.codings:
          codings.value.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(covariant TextCodingVersion other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  Future<void> _makeCodingLines() async {
    _codingLines?.value.clear();
    for (final line in file.textLines.value) {
      final codingLine = TextCodingLine(textLine: line);
      for (final coding in codings.value) {
        if (line.offset <= coding.start && coding.start < line.endOffset) {
          codingLine.codings.value.add(coding);
        } else if (line.offset < coding.end && coding.end < line.endOffset) {
          codingLine.codings.value.add(coding);
        }
      }
      _codingLines?.value.add(codingLine);
    }
  }

  void removeCode(Code code) {
    if (_codingLines != null) {
      for (final line in _codingLines!.value) {
        line.codings.value.removeWhere((c) => c.code == code);
        line.codings.notify();
      }
    }
    codings.value.removeWhere((c) => c.code == code);
    codings.notify();
  }

  void addCoding(TextCodingLine line, Code code, int offset, int length) {
    final coding = TextCoding(
      code: code,
      start: line.textLine.offset + offset,
      length: length,
    );
    line.codings.value.add(coding);
    line.codings.notify();
    codings.value.add(coding);
    codings.notify();
  }

  void updatedCode(Code code) {
    for (var line in _codingLines?.value ?? []) {
      if (line.codings.value.map((c) => c.code).contains(code)) {
        line.codings.notify();
      }
    }
  }
}

class TextCodingVersionJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const codings = 'codings';
}

class TextCodingLine {
  final TextLine textLine;
  final codings = Observable<Set<TextCoding>>({});

  TextCodingLine({required this.textLine});
}
