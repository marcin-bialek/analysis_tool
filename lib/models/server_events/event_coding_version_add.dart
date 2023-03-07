import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/models/server_events/server_event.dart';
import 'package:qdamono/models/text_coding_version.dart';
import 'package:qdamono/models/text_file.dart';

class EventCodingVersionAdd extends ServerEvent {
  static const name = 'coding_version_add';
  final String textFileId;
  final TextCodingVersion codingVersion;

  EventCodingVersionAdd({
    required this.textFileId,
    required this.codingVersion,
  });

  factory EventCodingVersionAdd.fromJson(
    Map<String, dynamic> json,
    Iterable<TextFile> files,
    Iterable<Code> codes,
    Iterable<Note> notes,
  ) {
    final textFileId = json[EventCodingVersionAddJsonKeys.textFileId];
    final codingVersion = json[EventCodingVersionAddJsonKeys.codingVersion]
        as Map<String, dynamic>;
    return EventCodingVersionAdd(
      textFileId: textFileId,
      codingVersion: TextCodingVersion.fromJson(
        codingVersion,
        files.firstWhere((e) => e.id == textFileId),
        codes,
        notes,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodingVersionAddJsonKeys.name: name,
      EventCodingVersionAddJsonKeys.textFileId: textFileId,
      EventCodingVersionAddJsonKeys.codingVersion: codingVersion.toJson(),
    };
  }
}

class EventCodingVersionAddJsonKeys {
  static const name = 'name';
  static const textFileId = 'text_file_id';
  static const codingVersion = 'coding_version';
}
