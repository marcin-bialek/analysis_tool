import 'package:analysis_tool/models/observable.dart';
import 'package:analysis_tool/models/server_events/event_clients.dart';
import 'package:analysis_tool/models/server_events/event_get_project.dart';
import 'package:analysis_tool/models/server_events/event_hello.dart';
import 'package:analysis_tool/models/server_events/event_project.dart';
import 'package:analysis_tool/models/server_events/event_publish_project.dart';
import 'package:analysis_tool/models/server_events/event_published.dart';
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

  void _sendEvent(ServerEvent event) {
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
      _sendEvent(EventHello(clientId: clientId, username: 'dupa'));
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
    final event = ServerEvent.parse(e);
    if (event is EventClients) {
      connectionInfo.users.value = event.clients;
    } else if (event is EventProject) {
      ProjectService().project.value = event.project;
    } else if (event is EventPublished) {
      print('Published: passcode = ${event.passcode}');
    } else {
      print(event);
    }
  }

  Future<void> publishProject(String address) async {
    final project = ProjectService().project.value;
    if (project != null) {
      await _connect(address);
      _sendEvent(EventPublishProject(project: project));
    }
  }

  Future<void> connect(String address, String passcode) async {
    await _connect(address);
    _sendEvent(EventGetProject(passcode: passcode));
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
