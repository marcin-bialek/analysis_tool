import 'package:analysis_tool/models/server_events/server_event.dart';

class EventTextFileUpdate extends ServerEvent {
  static const name = 'textFileUpdate';
  final String textFileId;
  final String? textFileName;
  final String? rawText;

  EventTextFileUpdate({
    required this.textFileId,
    this.textFileName,
    this.rawText,
  });

  factory EventTextFileUpdate.fromJson(Map<String, dynamic> json) {
    final textFileId = json[EventTextFileUpdateJsonKeys.textFileId];
    final textFileName = json[EventTextFileUpdateJsonKeys.textFileName];
    final rawText = json[EventTextFileUpdateJsonKeys.rawText];
    return EventTextFileUpdate(
      textFileId: textFileId,
      textFileName: textFileName,
      rawText: rawText,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventTextFileUpdateJsonKeys.name: name,
      EventTextFileUpdateJsonKeys.textFileId: textFileId,
      EventTextFileUpdateJsonKeys.textFileName: textFileName,
      EventTextFileUpdateJsonKeys.rawText: rawText,
    };
  }
}

class EventTextFileUpdateJsonKeys {
  static const name = 'name';
  static const textFileId = 'textFileId';
  static const textFileName = 'textFileName';
  static const rawText = 'rawText';
}
