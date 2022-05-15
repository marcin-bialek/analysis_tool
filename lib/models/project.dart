import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:uuid/uuid.dart';

class Project implements JsonEncodable {
  final String id;
  final String name;
  final Set<TextFile> textFiles = {};
  final Set<Code> codes = {};
  final Set<TextCodingVersion> codingVersions = {};
  final Set<Note> notes = {};

  Project({
    required this.id,
    required this.name,
  });

  factory Project.withId({
    required String name,
  }) {
    final id = const Uuid().v4();
    return Project(id: id, name: name);
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    final id = json[ProjectJsonKeys.id];
    final name = json[ProjectJsonKeys.name];
    final project = Project(id: id, name: name);
    final textFiles = json[ProjectJsonKeys.textFiles] as List;
    project.textFiles.addAll(textFiles.map((e) => TextFile.fromJson(e)));
    final codes = json[ProjectJsonKeys.codes] as List;
    project.codes.addAll(codes.map((e) => Code.fromJson(e)));
    final codingVersions = json[ProjectJsonKeys.codingVersions] as List;
    project.codingVersions.addAll(codingVersions.map((e) =>
        TextCodingVersion.fromJson(e, project.textFiles, project.codes)));
    final notes = json[ProjectJsonKeys.notes] as List;
    project.notes.addAll(notes.map((e) => Note.fromJson(e)));
    return project;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ProjectJsonKeys.id: id,
      ProjectJsonKeys.name: name,
      ProjectJsonKeys.textFiles: textFiles.map((e) => e.toJson()).toList(),
      ProjectJsonKeys.codes: codes.map((e) => e.toJson()).toList(),
      ProjectJsonKeys.codingVersions:
          codingVersions.map((e) => e.toJson()).toList(),
      ProjectJsonKeys.notes: notes.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(covariant Project other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ProjectJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const textFiles = 'textFiles';
  static const codes = 'codes';
  static const codingVersions = 'codingVersions';
  static const notes = 'notes';
}
