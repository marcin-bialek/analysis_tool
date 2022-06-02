import 'package:analysis_tool/models/server_events/server_event.dart';

class EventCodingVersionUpdate extends ServerEvent {
  static const name = 'codingVersionUpdate';
  final String textFileId;
  final String codingVersionId;
  final String? codingVersionName;

  EventCodingVersionUpdate({
    required this.textFileId,
    required this.codingVersionId,
    this.codingVersionName,
  });

  factory EventCodingVersionUpdate.fromJson(Map<String, dynamic> json) {
    final textFileId = json[EventCodingVersionUpdateJsonKeys.textFileId];
    final codingVersionId =
        json[EventCodingVersionUpdateJsonKeys.codingVersionId];
    final codingVersionName =
        json[EventCodingVersionUpdateJsonKeys.codingVersionName];
    return EventCodingVersionUpdate(
      textFileId: textFileId,
      codingVersionId: codingVersionId,
      codingVersionName: codingVersionName,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodingVersionUpdateJsonKeys.name: name,
      EventCodingVersionUpdateJsonKeys.textFileId: textFileId,
      EventCodingVersionUpdateJsonKeys.codingVersionId: codingVersionId,
      EventCodingVersionUpdateJsonKeys.codingVersionName: codingVersionName,
    };
  }
}

class EventCodingVersionUpdateJsonKeys {
  static const name = 'name';
  static const textFileId = 'textFileId';
  static const codingVersionId = 'codingVersionId';
  static const codingVersionName = 'codingVersionName';
}
