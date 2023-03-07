import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/server_events/server_event.dart';
import 'package:qdamono/models/text_coding.dart';

class EventCodingAdd extends ServerEvent {
  static const name = 'coding_add';
  final String textFileId;
  final String codingVersionId;
  final int codingLineIndex;
  final TextCoding coding;

  EventCodingAdd({
    required this.textFileId,
    required this.codingVersionId,
    required this.codingLineIndex,
    required this.coding,
  });

  factory EventCodingAdd.fromJson(
    Map<String, dynamic> json,
    Iterable<Code> codes,
  ) {
    final textFileId = json[EventCodingAddJsonKeys.textFileId];
    final codingVersionId = json[EventCodingAddJsonKeys.codingVersionId];
    final coding = json[EventCodingAddJsonKeys.coding] as Map<String, dynamic>;
    final codingLineIndex = json[EventCodingAddJsonKeys.codingLineIndex];
    return EventCodingAdd(
      textFileId: textFileId,
      codingVersionId: codingVersionId,
      codingLineIndex: codingLineIndex,
      coding: TextCoding.fromJson(coding, codes),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodingAddJsonKeys.name: name,
      EventCodingAddJsonKeys.textFileId: textFileId,
      EventCodingAddJsonKeys.codingVersionId: codingVersionId,
      EventCodingAddJsonKeys.codingLineIndex: codingLineIndex,
      EventCodingAddJsonKeys.coding: coding.toJson(),
    };
  }
}

class EventCodingAddJsonKeys {
  static const name = 'name';
  static const textFileId = 'text_file_id';
  static const codingVersionId = 'coding_version_id';
  static const codingLineIndex = 'coding_line_index';
  static const coding = 'coding';
}
