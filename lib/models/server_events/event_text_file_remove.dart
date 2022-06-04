import 'package:qdamono/models/server_events/server_event.dart';

class EventTextFileRemove extends ServerEvent {
  static const name = 'textFileRemove';
  final String textFileId;

  EventTextFileRemove({
    required this.textFileId,
  });

  factory EventTextFileRemove.fromJson(Map<String, dynamic> json) {
    final textFileId = json[EventTextFileRemoveJsonKeys.textFileId];
    return EventTextFileRemove(textFileId: textFileId);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventTextFileRemoveJsonKeys.name: name,
      EventTextFileRemoveJsonKeys.textFileId: textFileId,
    };
  }
}

class EventTextFileRemoveJsonKeys {
  static const name = 'name';
  static const textFileId = 'textFileId';
}
