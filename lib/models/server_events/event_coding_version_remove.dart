import 'package:qdamono/models/server_events/server_event.dart';

class EventCodingVersionRemove extends ServerEvent {
  static const name = 'codingVersionRemove';
  final String textFileId;
  final String codingVersionId;

  EventCodingVersionRemove({
    required this.textFileId,
    required this.codingVersionId,
  });

  factory EventCodingVersionRemove.fromJson(Map<String, dynamic> json) {
    final textFileId = json[EventCodingVersionRemoveJsonKeys.name];
    final codingVersionId =
        json[EventCodingVersionRemoveJsonKeys.codingVersionId];
    return EventCodingVersionRemove(
      textFileId: textFileId,
      codingVersionId: codingVersionId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodingVersionRemoveJsonKeys.name: name,
      EventCodingVersionRemoveJsonKeys.textFileId: textFileId,
      EventCodingVersionRemoveJsonKeys.codingVersionId: codingVersionId,
    };
  }
}

class EventCodingVersionRemoveJsonKeys {
  static const name = 'name';
  static const textFileId = 'textFileId';
  static const codingVersionId = 'codingVersionId';
}
