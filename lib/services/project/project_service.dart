import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:analysis_tool/models/server_events/event_coding_version_update.dart';
import 'package:analysis_tool/models/server_events/event_text_file_update.dart';

import './desktop_saver.dart' if (dart.library.html) './web_saver.dart'
    as saver;

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
import 'package:analysis_tool/models/server_events/event_note_update.dart';
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
        if (kDebugMode) {
          print(e);
        }
        throw InvalidFileError();
      }
    }
    return null;
  }

  void closeProject() {
    ServerService().disconnect();
    project.value = null;
    _currentProjectPath = null;
  }

  Future<bool> saveProjectAs() async {
    final project = _getOrCreateProject();
    if (kIsWeb) {
      await saver.save('projekt.atool', jsonEncode(project.toJson()));
    } else {
      final path = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: [projectFileExtension],
      );
      if (path != null) {
        await saver.save(path, jsonEncode(project.toJson()));
        _currentProjectPath = path;
      } else {
        return false;
      }
    }
    return true;
  }

  Future<bool> saveProject() async {
    final project = _getOrCreateProject();
    if (_currentProjectPath == null) {
      return await saveProjectAs();
    }
    await saver.save(_currentProjectPath!, jsonEncode(project.toJson()));
    return true;
  }

  Future<void> addFile() async {
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
          addTextFile(textFile);
          break;
        default:
          throw UnsupportedFileError();
      }
    }
  }

  void addTextFile(TextFile textFile, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    project.textFiles.value.add(textFile);
    project.textFiles.notify();
    if (sendToServer) {
      ServerService().sendEvent(EventTextFileAdd(textFile: textFile));
    }
  }

  void removeTextFile(TextFile textFile, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    if (project.textFiles.value.remove(textFile)) {
      project.textFiles.notify();
      for (final version in textFile.codingVersions.value) {
        for (final note in project.notes.value) {
          note.codingLines.remove(version.id);
        }
      }
      if (sendToServer) {
        ServerService().sendEvent(EventTextFileRemove(textFileId: textFile.id));
      }
    }
  }

  void updateTextFile(
    String id, {
    String? name,
    String? rawText,
    bool sendToServer = true,
  }) {
    final project = _getOrCreateProject();
    final textFile =
        project.textFiles.value.firstWhereOrNull((e) => e.id == id);
    if (textFile != null) {
      if (rawText != null && textFile.codingVersions.value.isNotEmpty) {
        return;
      }
      if (name != null) {
        textFile.name.value = name;
      }
      if (rawText != null) {
        textFile.rawText.value = rawText;
        textFile.makeTextLines();
      }
      if (sendToServer) {
        ServerService().sendEvent(EventTextFileUpdate(
            textFileId: id, textFileName: name, rawText: rawText));
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

  TextCodingVersion addCodingVersion(TextCodingVersion version,
      {bool sendToServer = true}) {
    version.file.codingVersions.value.add(version);
    version.file.codingVersions.notify();
    if (sendToServer) {
      ServerService().sendEvent(EventCodingVersionAdd(
        textFileId: version.file.id,
        codingVersion: version,
      ));
    }
    return version;
  }

  TextCodingVersion addNewCodingVersion(TextFile file,
      {bool sendToServer = true}) {
    final version = TextCodingVersion.withId(
      name: 'Wersja #${file.codingVersions.value.length + 1}',
      file: file,
    );
    return addCodingVersion(version, sendToServer: sendToServer);
  }

  void removeCodingVersion(TextCodingVersion version,
      {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    if (version.file.codingVersions.value.remove(version)) {
      version.file.codingVersions.notify();
      for (final note in project.notes.value) {
        note.codingLines.remove(version.id);
      }
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

  void updateCodingVersion(
    String id, {
    String? name,
    bool sendToServer = true,
  }) {
    final project = _getOrCreateProject();
    TextFile? textFile;
    TextCodingVersion? version;
    for (final file in project.textFiles.value) {
      version = file.codingVersions.value.firstWhereOrNull((e) => e.id == id);
      if (version != null) {
        textFile = file;
        break;
      }
    }
    if (textFile != null && version != null) {
      if (name != null) version.name.value = name;
      if (sendToServer) {
        ServerService().sendEvent(EventCodingVersionUpdate(
          textFileId: textFile.id,
          codingVersionId: id,
          codingVersionName: name,
        ));
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
    offset += line.textLine.offset;
    final end = offset + length;
    final intersecting = line.codings.value.where((c) {
      return c.code == code && offset <= c.end && c.start <= end;
    }).toList();
    final starts = intersecting.map((c) => c.start).toList();
    starts.add(offset);
    final s = starts.reduce((v, e) => v < e ? v : e);
    final ends = intersecting.map((c) => c.end).toList();
    ends.add(end);
    final e = ends.reduce((v, e) => v > e ? v : e);
    final coding = TextCoding(code: code, start: s, length: e - s);
    for (final i in intersecting) {
      removeCoding(version, i, sendToServer: sendToServer);
    }
    addCoding(version, line, coding, sendToServer: sendToServer);
  }

  void addCode(Code code, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    if (code.parentId == null) {
      project.codes.value.add(code);
      project.codes.notify();
    } else {
      final parent =
          project.codes.value.firstWhereOrNull((e) => e.id == code.parentId);
      if (parent != null) {
        project.codes.value.add(code);
        parent.children.value.add(code);
        parent.children.notify();
      }
    }
    if (sendToServer) {
      ServerService().sendEvent(EventCodeAdd(code: code));
    }
  }

  void addNewCode({Code? parent, bool sendToServer = true}) {
    final project = _getOrCreateProject();
    final color = parent == null
        ? Random().element(ColorTools.primaryColors)
        : parent.color.value;
    final code = Code.withId(
      name: 'Kod #${project.codes.value.length + 1}',
      color: color,
      parentId: parent?.id,
    );
    addCode(code, sendToServer: sendToServer);
  }

  void removeCode(Code code, {bool sendToServer = true}) {
    final project = _getOrCreateProject();
    if (project.codes.value.remove(code)) {
      for (final file in project.textFiles.value) {
        for (final codingVersion in file.codingVersions.value) {
          codingVersion.removeCode(code);
        }
      }
      project.codes.value
          .where((c) => c.parentId == code.id)
          .toList()
          .forEach((child) {
        removeCode(child, sendToServer: false);
      });
      if (code.parentId == null) {
        project.codes.notify();
      } else {
        final parent =
            project.codes.value.firstWhereOrNull((c) => c.id == code.parentId);
        if (parent != null) {
          parent.children.value.remove(code);
          parent.children.notify();
        }
      }
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
    addNote(Note.withId(
      title: 'Nowa notatka',
      text: 'Nowa notatka',
    ));
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

  void updateNote(
    String id, {
    String? title,
    String? text,
    bool sendToServer = true,
  }) {
    final project = _getOrCreateProject();
    final note = project.notes.value.firstWhereOrNull((e) => e.id == id);
    if (note != null) {
      if (title != null) note.title.value = title;
      if (text != null) note.text.value = text;
      if (sendToServer) {
        ServerService().sendEvent(EventNoteUpdate(
          noteId: id,
          title: title,
          text: text,
        ));
      }
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

  Future<Map<Code, List<CodeStats>>> getCodeStatsForVersion(
    TextCodingVersion version, {
    bool groupAdjacentLines = true,
  }) async {
    final project = _getOrCreateProject();
    final stats = <Code, List<CodeStats>>{};
    for (final code in project.codes.value) {
      final codeStats = <CodeStats>[];
      int? startLine;
      int? lastLine;
      String? text;

      for (final line in version.codingLines.value) {
        bool hasCode = false;
        for (final coding in line.codings.value) {
          if (coding.code != code) {
            continue;
          }
          lastLine = line.textLine.index;
          hasCode = true;
          if (startLine != null && line.textLine.offset < coding.start) {
            codeStats.add(CodeStats(code, version.file, version, startLine,
                line.textLine.index, text!));
            startLine = null;
            text = null;
          }
          final t = line.textLine.text.substring(
            coding.start - line.textLine.offset,
            coding.end - line.textLine.offset,
          );
          if (text == null) {
            text = t;
          } else {
            text += '\n$t';
          }
          if (coding.end < line.textLine.endOffset ||
              groupAdjacentLines == false) {
            codeStats.add(CodeStats(
              code,
              version.file,
              version,
              startLine ?? line.textLine.index,
              line.textLine.index,
              text,
            ));
            startLine = null;
            text = null;
          } else {
            startLine ??= line.textLine.index;
          }
        }
        if (startLine != null && !hasCode) {
          codeStats.add(CodeStats(code, version.file, version, startLine,
              line.textLine.index - 1, text!));
          startLine = null;
          text = null;
        }
      }

      if (startLine != null && text != null && lastLine != null) {
        codeStats.add(CodeStats(
          code,
          version.file,
          version,
          startLine,
          lastLine,
          text,
        ));
      }

      stats[code] = codeStats;
    }
    return stats;
  }

  Future<Map<Code, Map<TextCodingVersion, List<CodeStats>>>>
      getCodeStatsForTextFile(
    TextFile textFile, {
    bool groupAdjacentLines = true,
  }) async {
    final stats = <Code, Map<TextCodingVersion, List<CodeStats>>>{};
    for (final version in textFile.codingVersions.value) {
      final versionStats = await getCodeStatsForVersion(
        version,
        groupAdjacentLines: groupAdjacentLines,
      );
      for (final code in versionStats.keys) {
        if (versionStats[code]!.isNotEmpty) {
          if (!stats.containsKey(code)) {
            stats[code] = {};
          }
          stats[code]![version] = versionStats[code]!;
        }
      }
    }
    return stats;
  }

  Future<Map<Code, Map<TextFile, Map<TextCodingVersion, List<CodeStats>>>>>
      getGroupedCodeStats({
    bool groupAdjacentLines = true,
  }) async {
    final project = _getOrCreateProject();
    final stats =
        <Code, Map<TextFile, Map<TextCodingVersion, List<CodeStats>>>>{};
    for (final textFile in project.textFiles.value) {
      final fileStats = await getCodeStatsForTextFile(textFile,
          groupAdjacentLines: groupAdjacentLines);
      for (final code in fileStats.keys) {
        if (fileStats[code]!.isNotEmpty) {
          if (!stats.containsKey(code)) {
            stats[code] = {};
          }
          stats[code]![textFile] = fileStats[code]!;
        }
      }
    }
    return stats;
  }

  Future<List<CodeStats>> getCodeStats({bool groupAdjacentLines = true}) async {
    final project = _getOrCreateProject();
    final stats = <CodeStats>[];
    for (final textFile in project.textFiles.value) {
      for (final version in textFile.codingVersions.value) {
        final versionStats = await getCodeStatsForVersion(
          version,
          groupAdjacentLines: groupAdjacentLines,
        );
        for (final s in versionStats.values) {
          stats.addAll(s);
        }
      }
    }
    return stats;
  }

  Future<void> saveCodeStatsAsCSV({bool groupAdjacentLines = true}) async {
    final stats = await getCodeStats(groupAdjacentLines: groupAdjacentLines);
    stats.sort((a, b) => a.code.id.compareTo(b.code.id));
    final csv = const ListToCsvConverter().convert([
      ['Kod', 'Plik', 'Kodowanie', 'Linia', 'Tekst'],
      ...stats.map(
        (s) => [
          s.code.name.value,
          s.textFile.name.value,
          s.codingVersion.name.value,
          if (s.startLine == s.endLine) s.startLine + 1,
          if (s.startLine != s.endLine) '${s.startLine + 1}-${s.endLine + 1}',
          s.text,
        ],
      ),
    ]);
    if (kIsWeb) {
      await saver.save('kody.csv', csv);
    } else {
      final path = await FilePicker.platform.saveFile(
        type: FileType.custom,
        fileName: 'kody.csv',
        allowedExtensions: ['csv'],
      );
      if (path != null) {
        await saver.save(path, csv);
      }
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
  final int startLine;
  final int endLine;
  final String text;

  CodeStats(
    this.code,
    this.textFile,
    this.codingVersion,
    this.startLine,
    this.endLine,
    this.text,
  );
}
