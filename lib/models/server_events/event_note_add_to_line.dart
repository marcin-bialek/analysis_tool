import 'package:analysis_tool/models/server_events/server_event.dart';

class EventNoteAddToLine extends ServerEvent {
  static const name = 'noteAddToLine';
  final String codingVersionId;
  final int lineIndex;
  final String noteId;

  EventNoteAddToLine({
    required this.codingVersionId,
    required this.lineIndex,
    required this.noteId,
  });

  factory EventNoteAddToLine.fromJson(Map<String, dynamic> json) {
    final codingVersionId = json[EventNoteAddToLineJsonKeys.codingVersionId];
    final lineIndex = json[EventNoteAddToLineJsonKeys.lineIndex];
    final noteId = json[EventNoteAddToLineJsonKeys.noteId];
    return EventNoteAddToLine(
      codingVersionId: codingVersionId,
      lineIndex: lineIndex,
      noteId: noteId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventNoteAddToLineJsonKeys.name: name,
      EventNoteAddToLineJsonKeys.codingVersionId: codingVersionId,
      EventNoteAddToLineJsonKeys.lineIndex: lineIndex,
      EventNoteAddToLineJsonKeys.noteId: noteId,
    };
  }
}

class EventNoteAddToLineJsonKeys {
  static const name = 'name';
  static const codingVersionId = 'codingVersionId';
  static const lineIndex = 'lineIndex';
  static const noteId = 'noteId';
}
