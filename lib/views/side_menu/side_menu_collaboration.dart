import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdamono/providers/settings/settings.dart';
import 'package:qdamono/services/project/project_service.dart';
import 'package:qdamono/services/server/server_service.dart';
import 'package:qdamono/services/server/server_service_exceptions.dart';
import 'package:qdamono/views/dialogs.dart';

class SideMenuCollaboration extends ConsumerStatefulWidget {
  const SideMenuCollaboration({Key? key}) : super(key: key);

  @override
  ConsumerState<SideMenuCollaboration> createState() =>
      _SideMenuCollaborationState();
}

class _SideMenuCollaborationState extends ConsumerState<SideMenuCollaboration> {
  final _projectService = ProjectService();
  final _serverService = ServerService();
  final _serverAddressController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _serverAddressController.dispose();
    _passcodeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40.0,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: const Text('Konto'),
              ),
              const Spacer(),
            ],
          ),
        ),
        _serverService.userInfo.username.observe((accessToken) {
          final userIsLoggedIn =
              _serverService.userInfo.accessToken.value != '';

          if (userIsLoggedIn) {
            return SizedBox(
              height: 25.0,
              child: Row(
                children: [
                  const SizedBox(width: 20.0),
                  Text(
                    _serverService.userInfo.username.value,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(decoration: TextDecoration.underline),
                  ),
                  const Spacer(),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        }),
        _serverService.userInfo.accessToken.observe((accessToken) {
          final isLoggedIn = accessToken != '';

          return ListTile(
            enabled: true,
            dense: true,
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login,
                size: 20.0, color: isLoggedIn ? Colors.red : Colors.green),
            title: Text(
              isLoggedIn ? 'Wyloguj się' : 'Zaloguj się',
              style: TextStyle(
                color: isLoggedIn ? Colors.red : Colors.green,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () async {
              if (isLoggedIn) {
                await _logout(settings);
              } else {
                await _login(settings);
              }
            },
          );
        }),
        _serverService.userInfo.accessToken.observe((accessToken) {
          final isLoggedIn = accessToken != '';

          if (!isLoggedIn) {
            return ListTile(
              enabled: true,
              dense: true,
              leading: Icon(Icons.add_home,
                  size: 20.0, color: isLoggedIn ? Colors.red : Colors.green),
              title: Text(
                'Zarejestruj się',
                style: TextStyle(
                  color: isLoggedIn ? Colors.red : Colors.green,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () async {
                await _register(settings);
              },
            );
          }

          return const SizedBox.shrink();
        }),
        SizedBox(
          height: 40.0,
          child: Row(
            children: [
              const SizedBox(width: 20.0),
              Text(
                'Współpraca',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
            ],
          ),
        ),
        _serverService.userInfo.accessToken.observe((accessToken) {
          final userIsLoggedIn =
              _serverService.userInfo.accessToken.value != '';

          return _serverService.connectionInfo.state.observe((state) {
            return ListTile(
              enabled: _serverService.userInfo.accessToken.value != '' &&
                  state != ServerConnectionState.connecting,
              dense: true,
              leading: Icon(
                  settings.isConnectionSecure ? Icons.lock : Icons.cloud,
                  size: 20.0,
                  color: userIsLoggedIn ? Colors.green : Colors.grey),
              title: Text(
                <ServerConnectionState, String>{
                  ServerConnectionState.disconnected:
                      'Otwórz istniejący projekt',
                  ServerConnectionState.connecting: 'Łączenie...',
                  ServerConnectionState.connected:
                      'Otworzono projekt ${_projectService.project.value?.name}',
                }[state]!,
                style: TextStyle(
                  color: userIsLoggedIn ? Colors.green : Colors.grey,
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
                  await _openProject(settings);
                } else if (state == ServerConnectionState.connected) {
                  await showDialogConnectionInfo(
                    context: context,
                    passcode: _serverService.connectionInfo.passcode.value,
                  );
                }
              },
            );
          });
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
                  onTap: () => _publishProject(settings.serverAddress),
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
                style: Theme.of(context).textTheme.bodyMedium,
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
                      color: Theme.of(context).iconTheme.color,
                    ),
                    title: Text(
                      e.value +
                          (e.key == _serverService.connectionInfo.clientId.value
                              ? ' (Ty)'
                              : ''),
                      style: Theme.of(context).textTheme.bodyMedium,
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

  Future<void> _register(SettingsState settings) async {
    final result = await showGenericDialog(
      context: context,
      title: 'Zarejestruj się',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Podaj swój email',
              hintStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Podaj hasło',
              hintStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
        ],
      ),
      actions: {
        'Zarejestruj się': true,
        'Anuluj': false,
      },
    );

    if (result == true) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        await _serverService.register(settings, username, password);
      } on UserAlreadyExistsError {
        await showDialogUserAlreadyExists(context: context, email: username);
      } catch (e) {
        await showDialogCouldNotConnect(
            context: context, address: settings.serverAddress);
      }
    }
  }

  Future<void> _login(SettingsState settings) async {
    final result = await showGenericDialog(
      context: context,
      title: 'Zaloguj się',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Podaj swój email',
              hintStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Podaj hasło',
              hintStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
        ],
      ),
      actions: {
        'Zaloguj się': true,
        'Anuluj': false,
      },
    );

    if (result == true) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        await _serverService.login(settings, username, password);
      } on AuthenticationError {
        await showDialogAuthenticationFailed(
            context: context, username: username);
      } catch (_) {
        await showDialogCouldNotConnect(
            context: context, address: settings.serverAddress);
      }
    }
  }

  Future<void> _logout(SettingsState settings) async {
    await _serverService.logout(settings);
  }

  Future<void> _openProject(SettingsState settings) async {
    final result = await showGenericDialog<bool>(
      context: context,
      title: 'Otwórz projekt',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passcodeController,
            decoration: InputDecoration(
              hintText: 'Podaj kod projektu',
              hintStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      actions: {
        'Otwórz': true,
        'Anuluj': false,
      },
    );

    if (result == true) {
      final passcode = _passcodeController.text;

      try {
        await _serverService.connect(settings.serverAddress, passcode);
      } on CouldNotConnectError {
        await showDialogCouldNotConnect(
            context: context, address: settings.serverAddress);
      }
    }
  }

  Future<void> _publishProject(String serverAddress) async {
    final result = await showGenericDialog<bool>(
      context: context,
      title: 'Wyślij projekt na serwer',
      content:
          Text("Projekt zostanie opublikowany na serwerze: $serverAddress"),
      actions: {
        'Wyślij': true,
        'Anuluj': false,
      },
    );
    if (result == true) {
      try {
        await _serverService.publishProject(serverAddress);
      } on CouldNotConnectError {
        await showDialogCouldNotConnect(
            context: context, address: serverAddress);
      }
    }
  }
}
