import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/models/server_events/server_event.dart';

class EventNoteAdd extends ServerEvent {
  static const name = 'noteAdd';
  final Note note;

  EventNoteAdd({
    required this.note,
  });

  factory EventNoteAdd.fromJson(Map<String, dynamic> json) {
    final note = json['note'] as Map<String, dynamic>;
    return EventNoteAdd(note: Note.fromJson(note));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventNoteAddJsonKeys.name: name,
      EventNoteAddJsonKeys.note: note.toJson(),
    };
  }
}

class EventNoteAddJsonKeys {
  static const name = 'name';
  static const note = 'note';
}
