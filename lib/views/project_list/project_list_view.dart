import 'package:flutter/material.dart';
import 'package:qdamono/constants/privilege_level.dart';
import 'package:qdamono/models/project_info.dart';
import 'package:qdamono/services/server/server_service.dart';

class ProjectListView extends StatefulWidget {
  const ProjectListView({Key? key}) : super(key: key);

  @override
  State<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  final _serverService = ServerService();

  Future<void> refreshProjectList() async {
    await _serverService.getProjectList();
  }

  Widget listElement(ProjectInfo projectInfo) {
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
          onPressed: () async {
            await _serverService.connect(projectInfo.id);
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
                      onPressed: () async {
                        await refreshProjectList();
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
                    return listElement(project);
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
                    return listElement(project);
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
