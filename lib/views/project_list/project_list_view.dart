import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return _serverService.projectList.observe((value) {
      final length = _serverService.projectList.value.length;

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
                          style: Theme.of(context).primaryTextTheme.titleLarge,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Theme.of(context).colorScheme.onBackground),
          Column(
            children: _serverService.projectList.value.map((project) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.75),
                    ),
                    child: Text('${project.id}: ${project.name})',
                        style: Theme.of(context).primaryTextTheme.bodyLarge),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _serverService.connect(project.id);
                    },
                    icon: Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          length == 0
              ? Text(
                  'Brak projektów',
                  style:
                      Theme.of(context).primaryTextTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(192),
                          ),
                )
              : const SizedBox.shrink(),
        ],
      );
    });
  }
}
