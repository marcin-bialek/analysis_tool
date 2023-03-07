import 'package:qdamono/models/server_events/server_event.dart';

class EventNoteUpdate extends ServerEvent {
  static const name = 'note_update';
  final String noteId;
  final String? title;
  final String? text;

  EventNoteUpdate({
    required this.noteId,
    this.title,
    this.text,
  });

  factory EventNoteUpdate.fromJson(Map<String, dynamic> json) {
    final noteId = json[EventNoteUpdateJsonKeys.noteId];
    final title = json[EventNoteUpdateJsonKeys.title];
    final text = json[EventNoteUpdateJsonKeys.text];
    return EventNoteUpdate(
      noteId: noteId,
      title: title,
      text: text,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventNoteUpdateJsonKeys.name: name,
      EventNoteUpdateJsonKeys.noteId: noteId,
      if (title != null) EventNoteUpdateJsonKeys.title: title,
      if (text != null) EventNoteUpdateJsonKeys.text: text,
    };
  }
}

class EventNoteUpdateJsonKeys {
  static const name = 'name';
  static const noteId = 'note_id';
  static const title = 'title';
  static const text = 'text';
}
