import 'package:analysis_tool/models/observable.dart';
import 'package:analysis_tool/models/project.dart';
import 'package:analysis_tool/services/server/server_service_exceptions.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:uuid/uuid.dart';

class ServerService {
  static ServerService? _instance;
  final connectionInfo = ConnectionInfo();
  socket_io.Socket? _socket;

  ServerService._();

  factory ServerService() {
    _instance ??= ServerService._();
    return _instance!;
  }

  Future<void> publishProject(String address, Project project) async {}

  Future<ConnectionInfo> connect(String address, String passcode) async {
    address = address.trim();
    final options =
        socket_io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
      'atool-passcode': passcode,
      'atool-username': 'dupa',
      'atool-userid': const Uuid().v4(),
    }).build();
    final socket = socket_io.io(address.trim(), options);
    connectionInfo.state.value = ServerConnectionState.connecting;
    _socket = socket;
    socket.onConnect((_) {
      connectionInfo.state.value = ServerConnectionState.connected;
    });
    socket.onConnectError((error) {
      print(error);
      connectionInfo.state.value = ServerConnectionState.disconnected;
    });
    socket.on('message', _handleMessage);
    while (connectionInfo.state.value == ServerConnectionState.connecting) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (connectionInfo.state.value == ServerConnectionState.disconnected) {
      socket.close();
      throw CouldNotConnectError();
    }
    return connectionInfo;
  }

  void _handleMessage(dynamic data) {
    print('message ${data.runtimeType}');
    if (data is Map<String, dynamic>) {
      connectionInfo.users.value = data.cast();
    }
  }
}

class ConnectionInfo {
  final address = Observable('');
  final state = Observable(ServerConnectionState.disconnected);
  final users = Observable<Map<String, String>>({});
}

enum ServerConnectionState { disconnected, connecting, connected }
