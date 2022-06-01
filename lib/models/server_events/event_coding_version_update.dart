import 'package:analysis_tool/models/server_events/server_event.dart';

class EventCodingVersionUpdate extends ServerEvent {
  static const name = 'codingVersionUpdate';
  final String codingVersionId;
  final String? codingVersionName;

  EventCodingVersionUpdate({
    required this.codingVersionId,
    this.codingVersionName,
  });

  factory EventCodingVersionUpdate.fromJson(Map<String, dynamic> json) {
    final codingVersionId =
        json[EventCodingVersionUpdateJsonKeys.codingVersionId];
    final codingVersionName =
        json[EventCodingVersionUpdateJsonKeys.codingVersionName];
    return EventCodingVersionUpdate(
        codingVersionId: codingVersionId, codingVersionName: codingVersionName);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodingVersionUpdateJsonKeys.name: name,
      EventCodingVersionUpdateJsonKeys.codingVersionId: codingVersionId,
      EventCodingVersionUpdateJsonKeys.codingVersionName: codingVersionName,
    };
  }
}

class EventCodingVersionUpdateJsonKeys {
  static const name = 'name';
  static const codingVersionId = 'codingVersionId';
  static const codingVersionName = 'codingVersionName';
}
