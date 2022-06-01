import 'package:analysis_tool/services/project/project_service.dart';
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
  final _projectService = ProjectService();
  final _serverService = ServerService();
  final _serverAddressController = TextEditingController();
  final _passcodeController = TextEditingController();

  @override
  void dispose() {
    _serverAddressController.dispose();
    _passcodeController.dispose();
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
            children: [
              const SizedBox(width: 20.0),
              Text(
                'Współpraca',
                style: Theme.of(context).primaryTextTheme.bodyText2,
              ),
              const Spacer(),
            ],
          ),
        ),
        _serverService.connectionInfo.state.observe((state) {
          return ListTile(
            enabled: state != ServerConnectionState.connecting,
            dense: true,
            leading: Icon(
                _serverService.connectionInfo.secure.value
                    ? Icons.lock
                    : Icons.cloud,
                size: 20.0,
                color: Colors.green),
            title: Text(
              <ServerConnectionState, String>{
                ServerConnectionState.disconnected: 'Połącz z serwerem',
                ServerConnectionState.connecting: 'Łączenie...',
                ServerConnectionState.connected:
                    'Połączono z ${_serverService.connectionInfo.address.value}',
              }[state]!,
              style: const TextStyle(
                color: Colors.green,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: state == ServerConnectionState.connecting
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : null,
            onTap: () async {
              if (state == ServerConnectionState.disconnected) {
                await _connectToServer();
              } else if (state == ServerConnectionState.connected) {
                await showDialogConnectionInfo(
                  context: context,
                  address: _serverService.connectionInfo.address.value,
                  passcode: _serverService.connectionInfo.passcode.value,
                );
              }
            },
          );
        }),
        _serverService.connectionInfo.state.observe((state) {
          switch (state) {
            case ServerConnectionState.disconnected:
              return _projectService.project.observe((project) {
                if (project == null) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.cloud_upload,
                    size: 20.0,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    'Wyślij na serwer',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onTap: _publishProject,
                );
              });
            case ServerConnectionState.connected:
              return ListTile(
                dense: true,
                leading:
                    const Icon(Icons.cancel, size: 20.0, color: Colors.red),
                title: const Text(
                  'Rozłącz',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _serverService.disconnect,
              );
            default:
              return const SizedBox.shrink();
          }
        }),
        const SizedBox(height: 20.0),
        SizedBox(
          height: 40.0,
          child: Row(
            children: [
              const SizedBox(width: 20.0),
              Text(
                'Użytkownicy',
                style: Theme.of(context).primaryTextTheme.bodyText2,
              ),
              const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: _serverService.connectionInfo.users.observe((users) {
            return ListView(
              children: users.entries.map(
                (e) {
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.person,
                      size: 20.0,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    title: Text(
                      e.value +
                          (e.key == _serverService.clientId ? ' (Ty)' : ''),
                      style: Theme.of(context).primaryTextTheme.bodyText2,
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

  Future<void> _connectToServer() async {
    final result = await showGenericDialog<bool>(
      context: context,
      title: 'Połącz z serwerem',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _serverAddressController,
            decoration: const InputDecoration(
              hintText: 'Podaj adres serwera',
            ),
          ),
          TextField(
            controller: _passcodeController,
            decoration: const InputDecoration(
              hintText: 'Podaj kod projektu',
            ),
          ),
        ],
      ),
      actions: {
        'Połącz': true,
        'Anuluj': false,
      },
    );
    if (result == true) {
      final address = _serverAddressController.text;
      final passcode = _passcodeController.text;
      try {
        await _serverService.connect(address, passcode);
      } on CouldNotConnectError {
        await showDialogCouldNotConnect(context: context, address: address);
      }
    }
  }

  Future<void> _publishProject() async {
    final result = await showGenericDialog<bool>(
      context: context,
      title: 'Wyślij projekt na serwer',
      content: TextField(
        controller: _serverAddressController,
        decoration: const InputDecoration(
          hintText: 'Podaj adres serwera',
        ),
      ),
      actions: {
        'Wyślij': true,
        'Anuluj': false,
      },
    );
    if (result == true) {
      final address = _serverAddressController.text;
      try {
        await _serverService.publishProject(address);
      } on CouldNotConnectError {
        await showDialogCouldNotConnect(context: context, address: address);
      }
    }
  }
}
