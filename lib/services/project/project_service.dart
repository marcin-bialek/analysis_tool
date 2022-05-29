import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analysis_tool/extensions/iterable.dart';
import 'package:analysis_tool/extensions/random.dart';
import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/models/observable.dart';
import 'package:analysis_tool/models/project.dart';
import 'package:analysis_tool/models/server_events/event_code_add.dart';
import 'package:analysis_tool/models/server_events/event_code_remove.dart';
import 'package:analysis_tool/models/server_events/event_code_update.dart';
import 'package:analysis_tool/models/server_events/event_coding_add.dart';
import 'package:analysis_tool/models/server_events/event_coding_remove.dart';
import 'package:analysis_tool/models/server_events/event_coding_version_add.dart';
import 'package:analysis_tool/models/server_events/event_coding_version_remove.dart';
import 'package:analysis_tool/models/server_events/event_note_add.dart';
import 'package:analysis_tool/models/server_events/event_note_add_to_line.dart';
import 'package:analysis_tool/models/server_events/event_note_remove.dart';
import 'package:analysis_tool/models/server_events/event_note_remove_from_line.dart';
import 'package:analysis_tool/models/server_events/event_text_file_add.dart';
import 'package:analysis_tool/models/server_events/event_text_file_remove.dart';
import 'package:analysis_tool/models/text_coding.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service_exceptions.dart';
import 'package:analysis_tool/services/server/server_service.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart' show ColorTools;
import 'package:flutter/foundation.dart';

class ProjectService {
  static ProjectService? _instance;
  static const projectFileExtension = 'atool';

  final project = Observable<Project?>(null);
  String? _currentProjectPath;
  final _codeRequestStreamController = StreamController<Code>.broadcast();

  Stream<Code> get codeRequestStream => _codeRequestStreamController.stream;

  ProjectService._();

  factory ProjectService() {
    _instance ??= ProjectService._();
    return _instance!;
  }

  Project _getOrCreateProject() {
    project.value ??= Project.withId(name: 'new-project');
    return project.value!;
  }

  Future<Project?> openProject() async {
    if (project.value != null) {
      throw ProjectAlreadyOpenError();
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [projectFileExtension],
      withData: true,
    );
    if (result != null) {
      try {
        final file = const Utf8Decoder().convert(result.files.first.bytes!);
        final project = Project.fromJson(jsonDecode(file));
        this.project.value = project;
        _currentProjectPath = result.files.first.path;
        return project;
      } catch (e) {
        print(e);
        throw InvalidFileError();
      }
    }
    return null;
  }

  void closeProject() {
    project.value = null;
    _currentProjectPath = null;
  }

  Future<void> saveProjectAs() async {
    final project = _getOrCreateProject();
    if (kIsWeb) {
      // TODO: saving the project
      return;
    }
    final path = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: [projectFileExtension],
    );
    if (path != null) {
      await File(path).writeAsString(jsonEncode(project.toJson()));
      _currentProjectPath = path;
    }
  }

  Future<void> saveProject() async {
    final project = _getOrCreateProject();
    if (_currentProjectPath == null) {
      return await saveProjectAs();
    }
    await File(_currentProjectPath!)
        .writeAsString(jsonEncode(project.toJson()));
  }

  Future<void> addFile() async {
    final project = _getOrCreateProject();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: true,
    );
    if (result != null) {
      final file = result.files.first;
      final text = const Utf8Decoder().convert(file.bytes!);
      switch (file.extension) {
        case 'txt':
          final textFile = TextFile.withId(name: file.name, rawText: text);
          project.textFiles.value.add(textFile);
          project.textFiles.notify();
          ServerService().sendEvent(EventTextFileAdd(textFile: textFile));
          break;
        default:
          throw UnsupportedFileError();
      }
    }
  }

  void removeTextFile(TextFile textFile, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    if (project.textFiles.value.remove(textFile)) {
      project.textFiles.notify();
      if (sendToServer) {
        ServerService().sendEvent(EventTextFileRemove(textFileId: textFile.id));
      }
    }
  }

  void removeTextFileById(String id, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    final textFile =
        project.textFiles.value.firstWhereOrNull((e) => e.id == id);
    if (textFile != null) {
      removeTextFile(textFile, sendToServer: sendToServer);
    }
  }

  void addCodingVersion(TextFile file) {
    final version = TextCodingVersion.withId(
      name: 'Wersja #${file.codingVersions.value.length + 1}',
      file: file,
    );
    file.codingVersions.value.add(version);
    file.codingVersions.notify();
    ServerService().sendEvent(EventCodingVersionAdd(
      textFileId: file.id,
      codingVersion: version,
    ));
  }

  void removeCodingVersion(TextCodingVersion version,
      {bool sendToServer = true}) {
    if (version.file.codingVersions.value.remove(version)) {
      version.file.codingVersions.notify();
      if (sendToServer) {
        ServerService().sendEvent(EventCodingVersionRemove(
          textFileId: version.file.id,
          codingVersionId: version.id,
        ));
      }
    }
  }

  void removeCodingVersionById(String id, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    for (final textFile in project.textFiles.value) {
      final version =
          textFile.codingVersions.value.firstWhereOrNull((e) => e.id == id);
      if (version != null) {
        return removeCodingVersion(version, sendToServer: sendToServer);
      }
    }
  }

  void addCoding(
      TextCodingVersion version, TextCodingLine line, TextCoding coding,
      {bool sendToServer = true}) {
    line.codings.value.add(coding);
    line.codings.notify();
    version.codings.value.add(coding);
    version.codings.notify();
    if (sendToServer) {
      ServerService().sendEvent(EventCodingAdd(
        textFileId: version.file.id,
        codingVersionId: version.id,
        codingLineIndex: line.textLine.index,
        coding: coding,
      ));
    }
  }

  void removeCoding(TextCodingVersion version, TextCoding coding,
      {bool sendToServer = true}) {
    if (version.codings.value.remove(coding)) {
      version.codings.notify();
      for (final line in version.codingLines.value) {
        if (line.codings.value.remove(coding)) {
          line.codings.notify();
          break;
        }
      }
      if (sendToServer) {
        ServerService().sendEvent(EventCodingRemove(
          textFileId: version.file.id,
          codingVersionId: version.id,
          coding: coding,
        ));
      }
    }
  }

  void addNewCoding(TextCodingVersion version, TextCodingLine line, Code code,
      int offset, int length,
      {bool sendToServer = true}) {
    final coding = TextCoding(
      code: code,
      start: line.textLine.offset + offset,
      length: length,
    );
    addCoding(version, line, coding, sendToServer: sendToServer);
  }

  void addCode({bool sendToServer = true}) {
    final project = _getOrCreateProject();
    final code = Code.withId(
      name: 'Kod #${project.codes.value.length + 1}',
      color: Random().element(ColorTools.primaryColors),
    );
    project.codes.value.add(code);
    project.codes.notify();
    if (sendToServer) {
      ServerService().sendEvent(EventCodeAdd(code: code));
    }
  }

  void removeCode(Code code, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    if (project.codes.value.remove(code)) {
      for (final file in project.textFiles.value) {
        for (final codingVersion in file.codingVersions.value) {
          codingVersion.removeCode(code);
        }
      }
      project.codes.notify();
      if (sendToServer) {
        ServerService().sendEvent(EventCodeRemove(codeId: code.id));
      }
    }
  }

  void updatedCode(Code code, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    for (final textFile in project.textFiles.value) {
      for (var codingVersion in textFile.codingVersions.value) {
        codingVersion.updatedCode(code);
      }
    }
    if (sendToServer) {
      ServerService().sendEvent(EventCodeUpdate(
        codeId: code.id,
        codeName: code.name.value,
        codeColor: code.color.value,
      ));
    }
  }

  void addNote(Note note, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    project.notes.value.add(note);
    project.notes.notify();
    if (sendToServer) {
      ServerService().sendEvent(EventNoteAdd(note: note));
    }
  }

  void addEmptyNote() {
    final note = Note.withId(text: 'Nowa notatka');
    addNote(note);
  }

  void removeNote(Note note, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    if (project.notes.value.remove(note)) {
      project.notes.notify();
      for (final textFile in project.textFiles.value) {
        for (var codingVersion in textFile.codingVersions.value) {
          codingVersion.removeNote(note);
        }
      }
    }
    if (sendToServer) {
      ServerService().sendEvent(EventNoteRemove(noteId: note.id));
    }
  }

  void removeNoteById(String id, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    final note = project.notes.value.firstWhereOrNull((e) => e.id == id);
    if (note != null) {
      removeNote(note, sendToServer: sendToServer);
    }
  }

  void addNoteToCodingLine(TextCodingVersion version, int lineIndex, Note note,
      {bool sendToServer = true}) {
    note.codingLines.putIfAbsent(version.id, () => <int>{});
    note.codingLines[version.id]!.add(lineIndex);
    version.addNoteToLine(lineIndex, note);
    if (sendToServer) {
      ServerService().sendEvent(EventNoteAddToLine(
        codingVersionId: version.id,
        lineIndex: lineIndex,
        noteId: note.id,
      ));
    }
  }

  void addNoteToCodingLineByIds(String versionId, int lineIndex, String noteId,
      {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    TextCodingVersion? version;
    for (final textFile in project.textFiles.value) {
      version = textFile.codingVersions.value
          .firstWhereOrNull((v) => v.id == versionId);
      if (version != null) {
        break;
      }
    }
    final note = project.notes.value.firstWhereOrNull((n) => n.id == noteId);
    if (version != null && note != null) {
      addNoteToCodingLine(
        version,
        lineIndex,
        note,
        sendToServer: sendToServer,
      );
    }
  }

  void removeNoteFromCodingLine(
      TextCodingVersion version, int lineIndex, Note note,
      {bool sendToServer = true}) {
    note.codingLines[version.id]?.remove(lineIndex);
    version.removeNoteFromLine(lineIndex, note);
    if (sendToServer) {
      ServerService().sendEvent(EventNoteRemoveFromLine(
        codingVersionId: version.id,
        lineIndex: lineIndex,
        noteId: note.id,
      ));
    }
  }

  void removeNoteFromCodingLineByIds(
      String versionId, int lineIndex, String noteId,
      {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    TextCodingVersion? version;
    for (final textFile in project.textFiles.value) {
      version = textFile.codingVersions.value
          .firstWhereOrNull((v) => v.id == versionId);
      if (version != null) {
        break;
      }
    }
    final note = project.notes.value.firstWhereOrNull((n) => n.id == noteId);
    if (version != null && note != null) {
      removeNoteFromCodingLine(
        version,
        lineIndex,
        note,
        sendToServer: sendToServer,
      );
    }
  }

  void sendCodeRequest(Code code) {
    _codeRequestStreamController.add(code);
  }

  Stream<TextSearchResult> searchText(String text, {bool ignoreCase = false}) {
    final project = _getOrCreateProject();
    if (ignoreCase) {
      text = text.toLowerCase();
    }
    bool stopSearch = false;
    final controller = StreamController<TextSearchResult>(onCancel: () {
      stopSearch = true;
    });
    (() async {
      for (final file in project.textFiles.value) {
        if (stopSearch) {
          return;
        }
        final textLines = file.textLines.value;
        for (int i = 0; i < textLines.length; i++) {
          if (stopSearch) {
            return;
          }
          int offset;
          if (ignoreCase) {
            offset = textLines[i].text.toLowerCase().indexOf(text);
          } else {
            offset = textLines[i].text.indexOf(text);
          }
          if (offset >= 0) {
            controller.add(TextSearchResult(
              file,
              textLines[i],
              offset,
              text.length,
            ));
          }
        }
      }
      await controller.close();
    })();
    return controller.stream;
  }

  Future<List<CodeStats>> getCodeStats() async {
    final project = _getOrCreateProject();
    final stats = <CodeStats>[];
    for (final textFile in project.textFiles.value) {
      for (final codingVersion in textFile.codingVersions.value) {
        for (final line in codingVersion.codingLines.value) {
          for (var coding in line.codings.value) {
            final text = line.textLine.text.substring(
              coding.start - line.textLine.offset,
              coding.end - line.textLine.offset,
            );
            stats.add(CodeStats(
              coding.code,
              textFile,
              codingVersion,
              line.textLine.index,
              text,
            ));
          }
        }
      }
    }
    return stats;
  }

  Future<Map<Code, Map<TextFile, Map<TextCodingVersion, List<CodeStats>>>>>
      getGroupedCodeStats() async {
    final stats = await getCodeStats();
    final codes = stats.map((s) => s.code).toSet();
    return Map.fromEntries(codes.map((code) {
      final statsCode = stats.where((s) => s.code == code);
      final files = statsCode.map((s) => s.textFile).toSet();
      return MapEntry(code, Map.fromEntries(files.map((file) {
        final statsFile = statsCode.where((s) => s.textFile == file);
        final versions = statsFile.map((s) => s.codingVersion).toSet();
        return MapEntry(file, Map.fromEntries(versions.map((v) {
          return MapEntry(
              v, statsFile.where((s) => s.codingVersion == v).toList());
        })));
      })));
    }));
  }

  Future<void> saveCodeStatsAsCSV() async {
    final stats = await getCodeStats();
    stats.sort((a, b) => a.code.id.compareTo(b.code.id));
    final csv = const ListToCsvConverter().convert([
      ['Kod', 'Plik', 'Kodowanie', 'Linia', 'Tekst'],
      ...stats.map(
        (s) => [
          s.code.name.value,
          s.textFile.name.value,
          s.codingVersion.name.value,
          s.line + 1,
          s.text,
        ],
      ),
    ]);
    final path = await FilePicker.platform.saveFile(
      type: FileType.custom,
      fileName: 'kody.csv',
      allowedExtensions: ['csv'],
    );
    if (path != null) {
      await File(path).writeAsString(csv);
    }
  }
}

class TextSearchResult {
  final TextFile file;
  final TextLine line;
  final int offset;
  final int length;

  TextSearchResult(this.file, this.line, this.offset, this.length);
}

class CodeStats {
  final Code code;
  final TextFile textFile;
  final TextCodingVersion codingVersion;
  final int line;
  final String text;

  CodeStats(this.code, this.textFile, this.codingVersion, this.line, this.text);
}
