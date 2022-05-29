import 'package:analysis_tool/models/server_events/server_event.dart';

class EventNoteRemoveFromLine extends ServerEvent {
  static const name = 'noteRemoveFromLine';
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
  static const codingVersionId = 'codingVersionId';
  static const lineIndex = 'lineIndex';
  static const noteId = 'noteId';
}
