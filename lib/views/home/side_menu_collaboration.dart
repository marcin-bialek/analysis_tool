import 'package:analysis_tool/services/server/server_service.dart';
import 'package:analysis_tool/services/server/server_service_exceptions.dart';
import 'package:analysis_tool/views/dialogs.dart';
import 'package:flutter/material.dart';

class SideMenuCollaboration extends StatefulWidget {
  const SideMenuCollaboration({Key? key}) : super(key: key);

  @override
  State<SideMenuCollaboration> createState() => _SideMenuCollaborationState();
}

class _SideMenuCollaborationState extends State<SideMenuCollaboration> {
  final _serverService = ServerService();
  final _serverAddressController = TextEditingController();

  @override
  void dispose() {
    _serverAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40.0,
          child: Row(
            children: const [
              SizedBox(width: 20.0),
              Text(
                'Współpraca',
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
            ],
          ),
        ),
        _serverService.connectionInfo.state.observe((state) {
          return ListTile(
            enabled: state == ServerConnectionState.disconnected,
            dense: true,
            leading: const Icon(Icons.cloud, size: 20.0, color: Colors.green),
            title: Text(
              <ServerConnectionState, String>{
                ServerConnectionState.disconnected: 'Połącz z serwerem',
                ServerConnectionState.connecting: 'Łączenie...',
                ServerConnectionState.connected: 'Połączono',
              }[state]!,
              style: const TextStyle(color: Colors.green),
            ),
            trailing: state == ServerConnectionState.connecting
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : null,
            onTap: () {
              _connectToServer(context: context);
            },
          );
        }),
        _serverService.connectionInfo.state.observe((state) {
          return ListTile(
            enabled: state == ServerConnectionState.disconnected,
            dense: true,
            leading:
                const Icon(Icons.ios_share, size: 20.0, color: Colors.blue),
            title: const Text(
              'Wyślij na serwer',
              style: TextStyle(color: Colors.blue),
            ),
            // trailing: const SizedBox(
            //   width: 20.0,
            //   height: 20.0,
            //   child: CircularProgressIndicator(color: Colors.green),
            // ),
            onTap: () {
              // _connectToServer(context: context);
            },
          );
        }),
        SizedBox(
          height: 40.0,
          child: Row(
            children: const [
              SizedBox(width: 20.0),
              Text(
                'Użytkownicy',
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
            ],
          ),
        ),
        Expanded(
          child: _serverService.connectionInfo.users.observe((users) {
            return ListView(
              children: users.entries.map(
                (e) {
                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(
                      e.value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ).toList(),
            );
          }),
        ),
      ],
    );
  }

  void _connectToServer({required BuildContext context}) async {
    final result = await showGenericDialog<bool>(
      context: context,
      title: 'Połącz z serwerem',
      content: TextField(
        controller: _serverAddressController,
        decoration: const InputDecoration(
          hintText: 'Podaj adres serwera',
        ),
      ),
      actions: {
        'Połącz': true,
        'Anuluj': false,
      },
    );
    if (result == true) {
      final address = _serverAddressController.text;
      try {
        await ServerService().connect(address, '');
      } on CouldNotConnectError {
        await showDialogCouldNotConnect(context: context, address: address);
      }
    }
  }
}
