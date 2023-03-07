import 'package:qdamono/models/server_events/server_event.dart';

class EventNoteRemove extends ServerEvent {
  static const name = 'note_remove';
  final String noteId;

  EventNoteRemove({
    required this.noteId,
  });

  factory EventNoteRemove.fromJson(Map<String, dynamic> json) {
    final noteId = json[EventNoteRemoveJsonKeys.noteId] as String;
    return EventNoteRemove(noteId: noteId);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventNoteRemoveJsonKeys.name: name,
      EventNoteRemoveJsonKeys.noteId: noteId,
    };
  }
}

class EventNoteRemoveJsonKeys {
  static const name = 'name';
  static const noteId = 'note_id';
}
