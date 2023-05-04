import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdamono/constants/privilege_level.dart';
import 'package:qdamono/models/project_info.dart';
import 'package:qdamono/providers/settings/settings.dart';
import 'package:qdamono/services/server/server_service.dart';

class ProjectListView extends ConsumerStatefulWidget {
  const ProjectListView({Key? key}) : super(key: key);

  @override
  ConsumerState<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends ConsumerState<ProjectListView> {
  final _serverService = ServerService();

  Future<void> refreshProjectList(String serverAddress) async {
    await _serverService.getProjectList(serverAddress);
  }

  Widget listElement(ProjectInfo projectInfo, String? serverAddress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(20.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
          ),
          child: Text(
            '${projectInfo.id}\n${projectInfo.name}',
            style: Theme.of(context).primaryTextTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: serverAddress == null
              ? null
              : () async {
                  await _serverService.connect(serverAddress, projectInfo.id);
                },
          icon: Icon(
            Icons.open_in_new,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final serverAddress = ref.watch(
        settingsProvider.select((aValue) => aValue.valueOrNull?.serverAddress));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 20.0,
                  top: 40.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: serverAddress == null
                          ? null
                          : () async {
                              await refreshProjectList(serverAddress);
                            },
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Dostępne projekty',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Divider(color: Theme.of(context).colorScheme.surfaceVariant),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Moje i udostępnione projekty",
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        _serverService.projectList.observe((value) {
          final length = _serverService.projectList.value.length;

          return length != 0
              ? Column(
                  children: _serverService.projectList.value
                      .where((element) =>
                          element.privilegeLevel.value >
                          PrivilegeLevel.guest.value)
                      .map((project) {
                    return listElement(project, serverAddress);
                  }).toList(),
                )
              : Text(
                  'Brak projektów',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withAlpha(63),
                      ),
                );
        }),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Publiczne projekty",
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        _serverService.projectList.observe((value) {
          final length = _serverService.projectList.value.length;

          return length != 0
              ? Column(
                  children: _serverService.projectList.value
                      .where(
                    (element) =>
                        element.privilegeLevel.value <=
                        PrivilegeLevel.guest.value,
                  )
                      .map((project) {
                    return listElement(project, serverAddress);
                  }).toList(),
                )
              : Text(
                  'Brak projektów',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withAlpha(63),
                      ),
                );
        }),
      ],
    );
  }
}
