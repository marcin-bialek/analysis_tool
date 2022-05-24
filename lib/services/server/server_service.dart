import 'package:analysis_tool/extensions/iterable.dart';
import 'package:analysis_tool/models/observable.dart';
import 'package:analysis_tool/models/server_events/event_clients.dart';
import 'package:analysis_tool/models/server_events/event_code_add.dart';
import 'package:analysis_tool/models/server_events/event_code_remove.dart';
import 'package:analysis_tool/models/server_events/event_code_update.dart';
import 'package:analysis_tool/models/server_events/event_get_project.dart';
import 'package:analysis_tool/models/server_events/event_hello.dart';
import 'package:analysis_tool/models/server_events/event_note_add.dart';
import 'package:analysis_tool/models/server_events/event_note_remove.dart';
import 'package:analysis_tool/models/server_events/event_note_update.dart';
import 'package:analysis_tool/models/server_events/event_project.dart';
import 'package:analysis_tool/models/server_events/event_publish_project.dart';
import 'package:analysis_tool/models/server_events/event_published.dart';
import 'package:analysis_tool/models/server_events/event_text_file_add.dart';
import 'package:analysis_tool/models/server_events/event_text_file_remove.dart';
import 'package:analysis_tool/models/server_events/server_event.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/services/server/server_service_exceptions.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:uuid/uuid.dart';

class ServerService {
  static ServerService? _instance;
  final connectionInfo = ConnectionInfo();
  final clientId = const Uuid().v4();
  socket_io.Socket? _socket;

  ServerService._();

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
    final options = socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .enableForceNew()
        .build();
    final socket = socket_io.io(address.trim(), options);
    _socket = socket;
    connectionInfo.address.value = address;
    connectionInfo.state.value = ServerConnectionState.connecting;
    socket.onConnect((_) {
      connectionInfo.state.value = ServerConnectionState.connected;
      sendEvent(EventHello(clientId: clientId, username: 'dupa'));
    });
    socket.onConnectError((error) => disconnect());
    socket.onDisconnect((_) => disconnect());
    socket.on('event', _handleEvent);
    int time = 0;
    while (connectionInfo.state.value == ServerConnectionState.connecting) {
      await Future.delayed(const Duration(milliseconds: 100));
      time += 100;
      if (time >= 10000) {
        break;
      }
    }
    if (connectionInfo.state.value != ServerConnectionState.connected) {
      disconnect();
      throw CouldNotConnectError();
    }
    return connectionInfo;
  }

  void _handleEvent(dynamic e) {
    final projectService = ProjectService();
    final project = projectService.project.value;
    final event = ServerEvent.parse(e, codes: project?.codes.value);

    if (event is EventClients) {
      connectionInfo.users.value = event.clients;
    } else if (event is EventProject) {
      projectService.project.value = event.project;
    } else if (event is EventPublished) {
      print('Published: passcode = ${event.passcode}');
    }

    // TextFile events
    else if (event is EventTextFileAdd) {
      project?.textFiles.value.add(event.textFile);
      project?.textFiles.notify();
    } else if (event is EventTextFileRemove) {
      projectService.removeTextFileById(event.textFileId, sendToServer: false);
    }

    // Code events
    else if (event is EventCodeAdd) {
      project?.codes.value.add(event.code);
      project?.codes.notify();
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
      final note =
          project?.notes.value.firstWhereOrNull((n) => n.id == event.noteId);
      if (note != null) {
        if (event.text != null) note.text.value = event.text!;
      }
    } else {
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
    sendEvent(EventGetProject(passcode: passcode));
  }

  void disconnect() {
    connectionInfo.address.value = '';
    connectionInfo.state.value = ServerConnectionState.disconnected;
    connectionInfo.users.value = {};
    _socket?.dispose();
    _socket = null;
  }
}

class ConnectionInfo {
  final address = Observable('');
  final state = Observable(ServerConnectionState.disconnected);
  final users = Observable<Map<String, String>>({});
}

enum ServerConnectionState { disconnected, connecting, connected }
