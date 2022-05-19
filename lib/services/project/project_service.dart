import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analysis_tool/extensions/random.dart';
import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/models/project.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service_exceptions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart' show ColorTools;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProjectService {
  static ProjectService? _instance;
  static const projectFileExtension = 'atool';

  Project? _currentProject;
  String? _currentProjectPath;
  late final StreamController<List<TextFile>> _textFilesStreamController;
  late final StreamController<List<Code>> _codesStreamController;
  late final StreamController<List<Note>> _notesStreamController;

  get filesStream => _textFilesStreamController.stream;
  get codesStream => _codesStreamController.stream;
  get notesStream => _notesStreamController.stream;

  ProjectService._() {
    _textFilesStreamController = StreamController<List<TextFile>>.broadcast(
      onListen: () {
        if (_currentProject != null) {
          _textFilesStreamController.add(_currentProject!.textFiles.toList());
        }
      },
    );
    _codesStreamController = StreamController<List<Code>>.broadcast(
      onListen: () {
        if (_currentProject != null) {
          _codesStreamController.add(_currentProject!.codes.toList());
        }
      },
    );
    _notesStreamController = StreamController<List<Note>>.broadcast(
      onListen: () {
        if (_currentProject != null) {
          _notesStreamController.add(_currentProject!.notes.toList());
        }
      },
    );
  }

  factory ProjectService() {
    _instance ??= ProjectService._();
    return _instance!;
  }

  Project _getOrCreateProject() {
    _currentProject ??= Project.withId(name: 'new-project');
    return _currentProject!;
  }

  Future<Project?> openProject() async {
    if (_currentProject != null) {
      throw ProjectAlreadyOpenError();
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [projectFileExtension],
      withData: true,
    );
    if (result == null) {
      return null;
    }
    try {
      final file = const Utf8Decoder().convert(result.files.first.bytes!);
      final project = Project.fromJson(jsonDecode(file));
      _currentProject = project;
      _currentProjectPath = result.files.first.path;
      _textFilesStreamController.add(project.textFiles.toList());
      return project;
    } catch (e) {
      print(e);
      throw InvalidFileError();
    }
  }

  void closeProject() {
    _currentProject = null;
    _currentProjectPath = null;
    _textFilesStreamController.add([]);
    _codesStreamController.add([]);
    _notesStreamController.add([]);
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
          final textFile = TextFile.fromText(file.name, text);
          project.textFiles.add(textFile);
          _textFilesStreamController.add(project.textFiles.toList());
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
      for (final file in project.textFiles) {
        if (stopSearch) {
          return;
        }
        for (int i = 0; i < file.textLines.length; i++) {
          if (stopSearch) {
            return;
          }
          final p = file.textLines[i].indexOf(text);
          if (p >= 0) {
            controller.add(TextSearchResult(file, i, p, text.length));
          }
        }
      }
      await controller.close();
    })();
    return controller.stream;
  }

  void addCode() {
    final project = _getOrCreateProject();
    final code = Code.withId(
      name: 'Kod #${project.codes.length + 1}',
      color: Random().element(ColorTools.primaryColors),
    );
    project.codes.add(code);
    _codesStreamController.add(project.codes.toList());
  }

  void removeCode(Code code) {
    final project = _getOrCreateProject();
    for (final codingVersion in project.codingVersions) {
      codingVersion.codings.removeWhere((c) => c.code == code);
    }
    project.codes.remove(code);
    _codesStreamController.add(project.codes.toList());
  }

  void updateCode(Code code, {String? name, Color? color}) {
    final project = _getOrCreateProject();
    if ([name, color].any((e) => e != null)) {
      code.name = name ?? code.name;
      code.color = color ?? code.color;
      _codesStreamController.add(project.codes.toList());
    }
  }

  void addEmptyNote() {
    final project = _getOrCreateProject();
    final note = Note.withId(text: 'Nowa notatka');
    project.notes.add(note);
    _notesStreamController.add(project.notes.toList());
  }

  void removeNote(Note note) {
    final project = _getOrCreateProject();
    if (project.notes.remove(note)) {
      _notesStreamController.add(project.notes.toList());
    }
  }

  void updateNote(Note note, String text) {
    final project = _getOrCreateProject();
    if (note.text != text) {
      note.text = text;
      _notesStreamController.add(project.notes.toList());
    }
  }
}

class TextSearchResult {
  final TextFile file;
  final int line;
  final int start;
  final int length;

  TextSearchResult(this.file, this.line, this.start, this.length);
}
