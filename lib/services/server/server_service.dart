import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:qdamono/extensions/iterable.dart';
import 'package:qdamono/models/observable.dart';
import 'package:qdamono/models/project_info.dart';
import 'package:qdamono/models/server_events/event_client_id.dart';
import 'package:qdamono/models/server_events/event_clients.dart';
import 'package:qdamono/models/server_events/event_code_add.dart';
import 'package:qdamono/models/server_events/event_code_remove.dart';
import 'package:qdamono/models/server_events/event_code_update.dart';
import 'package:qdamono/models/server_events/event_coding_add.dart';
import 'package:qdamono/models/server_events/event_coding_remove.dart';
import 'package:qdamono/models/server_events/event_coding_version_add.dart';
import 'package:qdamono/models/server_events/event_coding_version_remove.dart';
import 'package:qdamono/models/server_events/event_coding_version_update.dart';
import 'package:qdamono/models/server_events/event_get_client_id.dart';
import 'package:qdamono/models/server_events/event_get_project.dart';
import 'package:qdamono/models/server_events/event_note_add.dart';
import 'package:qdamono/models/server_events/event_note_add_to_line.dart';
import 'package:qdamono/models/server_events/event_note_remove.dart';
import 'package:qdamono/models/server_events/event_note_remove_from_line.dart';
import 'package:qdamono/models/server_events/event_note_update.dart';
import 'package:qdamono/models/server_events/event_project.dart';
import 'package:qdamono/models/server_events/event_publish_project.dart';
import 'package:qdamono/models/server_events/event_published.dart';
import 'package:qdamono/models/server_events/event_text_file_add.dart';
import 'package:qdamono/models/server_events/event_text_file_remove.dart';
import 'package:qdamono/models/server_events/event_text_file_update.dart';
import 'package:qdamono/models/server_events/server_event.dart';
import 'package:qdamono/services/project/project_service.dart';
import 'package:qdamono/services/server/server_service_exceptions.dart';
import 'package:qdamono/services/server/unsecure_http_overrides.dart';
import 'package:qdamono/services/settings/settings_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class ServerService {
  static ServerService? _instance;
  final connectionInfo = ConnectionInfo();
  final userInfo = UserInfo();
  final projectList = Observable<List<ProjectInfo>>(List.empty());
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

  bool isConnectionAllowed() {
    return SettingsService().isConnectionSecure.value ||
        SettingsService().allowInsecureConnection.value;
  }

  Future<void> _register(String email, String password) async {
    final address = SettingsService().serverAddress.value;
    final response = await http.post(
      Uri.parse('$address/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 400) {
      final Map<String, dynamic> content = jsonDecode(response.body);

      if (content['detail'] is String &&
          content['detail'] == 'REGISTER_USER_ALREADY_EXISTS') {
        throw UserAlreadyExistsError('User $email already exists');
      }

      if (content['detail'] is Map<String, dynamic> &&
          content['detail']['code'] == 'REGISTER_INVALID_PASSWORD') {
        throw InvalidPasswordError(content['detail']['reason']);
      }
    }

    throw RegisterUserError("User registration unsuccessful");
  }

  Future<UserInfo> _login(String username, String password) async {
    final address = SettingsService().serverAddress.value;
    final request =
        http.MultipartRequest('POST', Uri.parse('$address/auth/login'))
          ..fields['username'] = username
          ..fields['password'] = password;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final Map<String, dynamic> content = jsonDecode(response.body);

    if (response.statusCode == 200) {
      userInfo.username.value = username;
      userInfo.password.value = password;
      userInfo.accessToken.value = content['access_token'];
      userInfo.accessToken.notify();
      userInfo.username.notify();
      userInfo.password.notify();
      return userInfo;
    }

    if (response.statusCode == 400) {
      final String detail = content['detail'];
      throw AuthenticationError('Login unsuccessful: $detail');
    }

    throw AuthenticationError('Login unsuccessful');
  }

  Future<UserInfo> _logout() async {
    final address = SettingsService().serverAddress.value;
    final accessToken = userInfo.accessToken.value;
    final response = await http.post(
      Uri.parse('$address/auth/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      userInfo.accessToken.value = '';
      userInfo.username.value = '';
      userInfo.password.value = '';
      userInfo.accessToken.notify();
      userInfo.username.notify();
      userInfo.password.notify();
      return userInfo;
    }

    if (response.statusCode == 401) {
      if (kDebugMode) {
        print('User is inactive');
      }
      return userInfo;
    }

    throw Exception(
        'Unexpected error during logout. Something might have happened to the server.');
  }

  Future<bool> checkAccessTokenIsValid() async {
    final address = SettingsService().serverAddress.value;
    final accessToken = userInfo.accessToken.value;
    final response = await http.get(
      Uri.parse('$address/auth/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    return response.statusCode == 200;
  }

  Future<List<ProjectInfo>> getProjectList() async {
    final address = SettingsService().serverAddress.value;
    final accessToken = userInfo.accessToken.value;
    final response = await http.get(
      Uri.parse('$address/project/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Iterable content = jsonDecode(response.body);
      projectList.value = content.map(
        (rawProjectInfo) {
          return ProjectInfo.fromJson(rawProjectInfo as Map<String, dynamic>);
        },
      ).toList();
      projectList.notify();
    }

    return projectList.value;
  }

  Future<ConnectionInfo> _connect(String address) async {
    if (_socket != null) {
      return connectionInfo;
    }

    address = address.trim();
    final completer = Completer<ConnectionInfo>();
    final options = socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': userInfo.accessToken.value})
        .enableForceNew()
        .build();
    final socket = socket_io.io(address, options);
    _socket = socket;
    connectionInfo.state.value = ServerConnectionState.connecting;

    socket.onConnect((_) {
      socket.onDisconnect((_) => disconnect());
      socket.on('event', _handleEvent);
      connectionInfo.state.value = ServerConnectionState.connected;
      sendEvent(EventGetClientId());
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

    if (event is EventClientId) {
      connectionInfo.clientId.value = event.clientId;
    } else if (event is EventClients) {
      connectionInfo.users.value = event.clients;
    } else if (event is EventProject) {
      projectService.project.value = event.project;
      if (event.project == null) {
        disconnect();
      }
      projectService.project.notify();
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
      projectService.addCodingVersion(event.codingVersion, sendToServer: false);
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
      print('Handle event: $event');
    }
  }

  Future<void> publishProject() async {
    final address = SettingsService().serverAddress.value;
    final project = ProjectService().project.value;
    if (project != null) {
      await _connect(address);
      sendEvent(EventPublishProject(project: project));
    }
  }

  Future<void> login(String username, String password) async {
    if (isConnectionAllowed()) {
      await _login(username, password);
    }
  }

  Future<void> logout() async {
    if (isConnectionAllowed()) {
      await _logout();
    }
  }

  Future<void> register(String email, String password) async {
    if (isConnectionAllowed()) {
      await _register(email, password);
      await login(email, password);
    }
  }

  Future<void> connect(String passcode) async {
    final address = SettingsService().serverAddress.value;
    await _connect(address);
    connectionInfo.passcode.value = passcode;
    connectionInfo.passcode.notify();
    sendEvent(EventGetProject(passcode: passcode));
  }

  void disconnect() {
    connectionInfo.passcode.value = '';
    connectionInfo.state.value = ServerConnectionState.disconnected;
    connectionInfo.users.value = {};
    connectionInfo.clientId.value = '';
    _socket?.dispose();
    _socket = null;
  }
}

class ConnectionInfo {
  final passcode = Observable('');
  final state = Observable(ServerConnectionState.disconnected);
  final users = Observable<Map<String, String>>({});
  final clientId = Observable('');
}

class UserInfo {
  final username = Observable('');
  final password = Observable('');
  final accessToken = Observable('');
}

enum ServerConnectionState { disconnected, connecting, connected }
