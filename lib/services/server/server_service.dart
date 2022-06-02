import 'dart:async';
import 'dart:io';

import 'package:analysis_tool/extensions/iterable.dart';
import 'package:analysis_tool/models/observable.dart';
import 'package:analysis_tool/models/server_events/event_clients.dart';
import 'package:analysis_tool/models/server_events/event_code_add.dart';
import 'package:analysis_tool/models/server_events/event_code_remove.dart';
import 'package:analysis_tool/models/server_events/event_code_update.dart';
import 'package:analysis_tool/models/server_events/event_coding_add.dart';
import 'package:analysis_tool/models/server_events/event_coding_remove.dart';
import 'package:analysis_tool/models/server_events/event_coding_version_add.dart';
import 'package:analysis_tool/models/server_events/event_coding_version_remove.dart';
import 'package:analysis_tool/models/server_events/event_coding_version_update.dart';
import 'package:analysis_tool/models/server_events/event_get_project.dart';
import 'package:analysis_tool/models/server_events/event_hello.dart';
import 'package:analysis_tool/models/server_events/event_note_add.dart';
import 'package:analysis_tool/models/server_events/event_note_add_to_line.dart';
import 'package:analysis_tool/models/server_events/event_note_remove.dart';
import 'package:analysis_tool/models/server_events/event_note_remove_from_line.dart';
import 'package:analysis_tool/models/server_events/event_note_update.dart';
import 'package:analysis_tool/models/server_events/event_project.dart';
import 'package:analysis_tool/models/server_events/event_publish_project.dart';
import 'package:analysis_tool/models/server_events/event_published.dart';
import 'package:analysis_tool/models/server_events/event_text_file_add.dart';
import 'package:analysis_tool/models/server_events/event_text_file_remove.dart';
import 'package:analysis_tool/models/server_events/event_text_file_update.dart';
import 'package:analysis_tool/models/server_events/server_event.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/services/server/server_service_exceptions.dart';
import 'package:analysis_tool/services/server/unsecure_http_overrides.dart';
import 'package:analysis_tool/services/settings/settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:uuid/uuid.dart';

class ServerService {
  static ServerService? _instance;
  final connectionInfo = ConnectionInfo();
  final clientId = const Uuid().v4();
  socket_io.Socket? _socket;

  ServerService._() {
    // if (kDebugMode) {
    HttpOverrides.global = UnsecureHttpOverrides();
    // }
  }

  factory ServerService() {
    _instance ??= ServerService._();
    return _instance!;
  }

  void sendEvent(ServerEvent event) {
    _socket?.emit('event', event.toJson());
  }

  Future<ConnectionInfo> _connect(String address) async {
    if (_socket != null) {
      return connectionInfo;
    }

    address = address.trim();
    final uri = Uri.parse(address);
    final completer = Completer<ConnectionInfo>();
    final options = socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .enableForceNew()
        .build();
    final socket = socket_io.io(address, options);
    _socket = socket;
    connectionInfo.address.value = address;
    connectionInfo.state.value = ServerConnectionState.connecting;

    socket.onConnect((_) {
      socket.onDisconnect((_) => disconnect());
      socket.on('event', _handleEvent);
      connectionInfo.state.value = ServerConnectionState.connected;
      if (uri.scheme == 'https' || uri.scheme == 'wss') {
        connectionInfo.secure.value = true;
      }
      sendEvent(EventHello(
        clientId: clientId,
        username: SettingsService().username.value,
      ));
      completer.complete(connectionInfo);
    });

    socket.onConnectError((error) {
      disconnect();
      if (!completer.isCompleted) {
        completer.completeError(CouldNotConnectError(error));
      }
    });

    return completer.future;
  }

  void _handleEvent(dynamic json) {
    final projectService = ProjectService();
    final project = projectService.project.value;
    final event = ServerEvent.parse(
      json,
      textFiles: project?.textFiles.value,
      codes: project?.codes.value,
      notes: project?.notes.value,
    );

    if (event is EventClients) {
      connectionInfo.users.value = event.clients;
    } else if (event is EventProject) {
      projectService.project.value = event.project;
      if (event.project == null) {
        disconnect();
      }
    } else if (event is EventPublished) {
      connectionInfo.passcode.value = event.passcode;
    }

    // TextFile events
    else if (event is EventTextFileAdd) {
      projectService.addTextFile(event.textFile, sendToServer: false);
    } else if (event is EventTextFileRemove) {
      projectService.removeTextFileById(event.textFileId, sendToServer: false);
    } else if (event is EventTextFileUpdate) {
      projectService.updateTextFile(
        event.textFileId,
        name: event.textFileName,
        rawText: event.rawText,
        sendToServer: false,
      );
    }

    // TextCodingVersion events
    else if (event is EventCodingVersionAdd) {
      final textFile = project?.textFiles.value
          .firstWhereOrNull((e) => e.id == event.textFileId);
      textFile?.codingVersions.value.add(event.codingVersion);
      textFile?.codingVersions.notify();
    } else if (event is EventCodingVersionRemove) {
      projectService.removeCodingVersionById(event.codingVersionId,
          sendToServer: false);
    } else if (event is EventCodingVersionUpdate) {
      projectService.updateCodingVersion(event.codingVersionId,
          name: event.codingVersionName, sendToServer: false);
    }

    // TextCoding events
    else if (event is EventCodingAdd) {
      final textFile = project?.textFiles.value
          .firstWhereOrNull((e) => e.id == event.textFileId);
      final version = textFile?.codingVersions.value
          .firstWhereOrNull((e) => e.id == event.codingVersionId);
      if (version != null) {
        ProjectService().addCoding(
          version,
          version.codingLines.value[event.codingLineIndex],
          event.coding,
          sendToServer: false,
        );
      }
    } else if (event is EventCodingRemove) {
      final textFile = project?.textFiles.value
          .firstWhereOrNull((e) => e.id == event.textFileId);
      final version = textFile?.codingVersions.value
          .firstWhereOrNull((e) => e.id == event.codingVersionId);
      if (version != null) {
        ProjectService()
            .removeCoding(version, event.coding, sendToServer: false);
      }
    }

    // Code events
    else if (event is EventCodeAdd) {
      projectService.addCode(event.code, sendToServer: false);
    } else if (event is EventCodeRemove) {
      final code =
          project?.codes.value.firstWhereOrNull((c) => c.id == event.codeId);
      if (code != null) {
        projectService.removeCode(code, sendToServer: false);
      }
    } else if (event is EventCodeUpdate) {
      final code =
          project?.codes.value.firstWhereOrNull((c) => c.id == event.codeId);
      if (code != null) {
        if (event.codeName != null) code.name.value = event.codeName!;
        if (event.codeColor != null) code.color.value = event.codeColor!;
        projectService.updatedCode(code, sendToServer: false);
      }
    }

    // Note events
    else if (event is EventNoteAdd) {
      projectService.addNote(event.note, sendToServer: false);
    } else if (event is EventNoteRemove) {
      projectService.removeNoteById(event.noteId, sendToServer: false);
    } else if (event is EventNoteUpdate) {
      projectService.updateNote(
        event.noteId,
        title: event.title,
        text: event.text,
        sendToServer: false,
      );
    } else if (event is EventNoteAddToLine) {
      projectService.addNoteToCodingLineByIds(
        event.codingVersionId,
        event.lineIndex,
        event.noteId,
        sendToServer: false,
      );
    } else if (event is EventNoteRemoveFromLine) {
      projectService.removeNoteFromCodingLineByIds(
        event.codingVersionId,
        event.lineIndex,
        event.noteId,
        sendToServer: false,
      );
    }

    // unknown event
    else if (kDebugMode) {
      print(event);
    }
  }

  Future<void> publishProject(String address) async {
    final project = ProjectService().project.value;
    if (project != null) {
      await _connect(address);
      sendEvent(EventPublishProject(project: project));
    }
  }

  Future<void> connect(String address, String passcode) async {
    await _connect(address);
    connectionInfo.passcode.value = passcode;
    sendEvent(EventGetProject(passcode: passcode));
  }

  void disconnect() {
    connectionInfo.address.value = '';
    connectionInfo.passcode.value = '';
    connectionInfo.state.value = ServerConnectionState.disconnected;
    connectionInfo.users.value = {};
    connectionInfo.secure.value = false;
    _socket?.dispose();
    _socket = null;
  }
}

class ConnectionInfo {
  final address = Observable('');
  final passcode = Observable('');
  final state = Observable(ServerConnectionState.disconnected);
  final users = Observable<Map<String, String>>({});
  final secure = Observable(false);
}

enum ServerConnectionState { disconnected, connecting, connected }
