import 'dart:convert';
import 'dart:io';

import 'package:analysis_tool/models/project.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service_exceptions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ProjectService {
  static ProjectService? _instance;
  static const projectFileExtension = 'atool';

  Project? _currentProject;
  String? _currentProjectPath;

  ProjectService._();

  factory ProjectService() {
    _instance ??= ProjectService._();
    return _instance!;
  }

  Project _getOrCreateProject() {
    return _currentProject ?? Project.withId(name: 'new-project');
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
      return project;
    } catch (e) {
      throw InvalidFileError();
    }
  }

  Future<void> closeProject() async {
    _currentProject = null;
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
          final textFile = TextFile.fromText(file.name, text);
          project.textFiles.add(textFile);
          break;
        default:
          throw UnsupportedFileError();
      }
    }
  }
}
