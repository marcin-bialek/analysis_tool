import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/server_events/server_event.dart';
import 'package:qdamono/models/text_coding.dart';

class EventCodingRemove extends ServerEvent {
  static const name = 'codingRemove';
  final String textFileId;
  final String codingVersionId;
  final TextCoding coding;

  EventCodingRemove({
    required this.textFileId,
    required this.codingVersionId,
    required this.coding,
  });

  factory EventCodingRemove.fromJson(
    Map<String, dynamic> json,
    Iterable<Code> codes,
  ) {
    final textFileId = json[EventCodingRemoveJsonKeys.textFileId];
    final codingVersionId = json[EventCodingRemoveJsonKeys.codingVersionId];
    final coding = json[EventCodingRemoveJsonKeys.coding];
    return EventCodingRemove(
      textFileId: textFileId,
      codingVersionId: codingVersionId,
      coding: TextCoding.fromJson(coding, codes),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodingRemoveJsonKeys.name: name,
      EventCodingRemoveJsonKeys.textFileId: textFileId,
      EventCodingRemoveJsonKeys.codingVersionId: codingVersionId,
      EventCodingRemoveJsonKeys.coding: coding.toJson(),
    };
  }
}

class EventCodingRemoveJsonKeys {
  static const name = 'name';
  static const textFileId = 'textFileId';
  static const codingVersionId = 'codingVersionId';
  static const coding = 'coding';
}
