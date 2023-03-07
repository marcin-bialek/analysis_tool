import 'package:qdamono/models/server_events/server_event.dart';

class EventNoteRemoveFromLine extends ServerEvent {
  static const name = 'note_remote_from_line';
  final String codingVersionId;
  final int lineIndex;
  final String noteId;

  EventNoteRemoveFromLine({
    required this.codingVersionId,
    required this.lineIndex,
    required this.noteId,
  });

  factory EventNoteRemoveFromLine.fromJson(Map<String, dynamic> json) {
    final codingVersionId =
        json[EventNoteRemoveFromLineJsonKeys.codingVersionId];
    final lineIndex = json[EventNoteRemoveFromLineJsonKeys.lineIndex];
    final noteId = json[EventNoteRemoveFromLineJsonKeys.noteId];
    return EventNoteRemoveFromLine(
      codingVersionId: codingVersionId,
      lineIndex: lineIndex,
      noteId: noteId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventNoteRemoveFromLineJsonKeys.name: name,
      EventNoteRemoveFromLineJsonKeys.codingVersionId: codingVersionId,
      EventNoteRemoveFromLineJsonKeys.lineIndex: lineIndex,
      EventNoteRemoveFromLineJsonKeys.noteId: noteId,
    };
  }
}

class EventNoteRemoveFromLineJsonKeys {
  static const name = 'name';
  static const codingVersionId = 'coding_version_id';
  static const lineIndex = 'line_index';
  static const noteId = 'note_id';
}
