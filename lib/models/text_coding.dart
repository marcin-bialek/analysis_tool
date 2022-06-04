import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/json_encodable.dart';

class TextCoding implements JsonEncodable {
  final Code code;
  final int start;
  final int length;
  int get end => start + length;

  const TextCoding({
    required this.code,
    required this.start,
    required this.length,
  });

  factory TextCoding.fromJson(Map<String, dynamic> json, Iterable<Code> codes) {
    final codeId = json[TextCodingJsonKeys.codeId];
    final code = codes.firstWhere((e) => e.id == codeId);
    final start = json[TextCodingJsonKeys.start];
    final length = json[TextCodingJsonKeys.length];
    return TextCoding(code: code, start: start, length: length);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextCodingJsonKeys.codeId: code.id,
      TextCodingJsonKeys.start: start,
      TextCodingJsonKeys.length: length,
    };
  }

  @override
  bool operator ==(covariant TextCoding other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => Object.hashAll([code, start, length]);
}

class TextCodingJsonKeys {
  static const codeId = 'codeId';
  static const start = 'start';
  static const length = 'length';
}
