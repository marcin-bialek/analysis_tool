import 'package:qdamono/models/server_events/server_event.dart';

class EventNoteAddToLine extends ServerEvent {
  static const name = 'note_add_to_line';
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
  static const codingVersionId = 'coding_version_id';
  static const lineIndex = 'line_index';
  static const noteId = 'note_id';
}
