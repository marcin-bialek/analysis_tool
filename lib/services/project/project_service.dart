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
import 'package:analysis_tool/models/server_events/event_note_add.dart';
import 'package:analysis_tool/models/server_events/event_note_remove.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service_exceptions.dart';
import 'package:analysis_tool/services/server/server_service.dart';
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
          break;
        default:
          throw UnsupportedFileError();
      }
    }
  }

  Stream<TextSearchResult> searchText(String text) {
    final project = _getOrCreateProject();
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
          final offset = textLines[i].text.indexOf(text);
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

  void addCodingVersion(TextFile file) {
    final version = TextCodingVersion.withId(
      name: 'Wersja #${file.codingVersions.value.length + 1}',
      file: file,
    );
    file.codingVersions.value.add(version);
    file.codingVersions.notify();
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

  void sendCodeRequest(Code code) {
    _codeRequestStreamController.add(code);
  }
}

class TextSearchResult {
  final TextFile file;
  final TextLine line;
  final int offset;
  final int length;

  TextSearchResult(this.file, this.line, this.offset, this.length);
}
