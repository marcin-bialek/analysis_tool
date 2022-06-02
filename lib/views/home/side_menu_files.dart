import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/views/dialogs.dart';
import 'package:analysis_tool/views/editable_text.dart';
import 'package:flutter/material.dart';

class SideMenuFiles extends StatefulWidget {
  const SideMenuFiles({Key? key}) : super(key: key);

  @override
  State<SideMenuFiles> createState() => _SideMenuFilesState();
}

class _SideMenuFilesState extends State<SideMenuFiles> {
  final _projectService = ProjectService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 20.0),
            Text(
              'Pliki',
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
            const Spacer(),
            IconButton(
              onPressed: _projectService.addFile,
              tooltip: 'Dodaj plik',
              icon: Icon(
                Icons.add,
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ),
            _projectService.project.observe((project) {
              if (project != null) {
                return Row(children: [
                  IconButton(
                    onPressed: _projectService.saveProject,
                    tooltip: 'Zapisz projekt',
                    icon: Icon(
                      Icons.save,
                      size: 20.0,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                  IconButton(
                    onPressed: _closeProject,
                    tooltip: 'Zamknij projekt',
                    icon: Icon(
                      Icons.close,
                      size: 20.0,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ]);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        Expanded(
          child: _projectService.project.observe((project) {
            if (project == null) {
              return Container();
            }
            return project.textFiles.observe((value) {
              final textFiles = value.toList();
              return ListView.builder(
                key: UniqueKey(),
                itemCount: textFiles.length,
                itemBuilder: (context, index) {
                  final file = textFiles[index];
                  return SideMenuFilesItem(file: file);
                },
              );
            });
          }),
        ),
      ],
    );
  }

  Future<void> _closeProject() async {
    final result = await showDialogSaveProject(context: context);
    if (result != null) {
      if (result == true) {
        if (await _projectService.saveProject() == false) {
          return;
        }
      }
      _projectService.closeProject();
      mainViewNavigatorKey.currentState!
          .pushReplacementNamed(MainViewRoutes.start);
    }
  }
}

class SideMenuFilesItem extends StatelessWidget {
  final TextFile file;

  const SideMenuFilesItem({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.file_copy,
            color: Theme.of(context).primaryIconTheme.color,
            size: 14.0,
          ),
          title: file.name.observe(
            (name) => TextEditable(
              text: name,
              style: Theme.of(context).primaryTextTheme.bodyText2,
              edited: (text) {
                ProjectService().updateTextFile(file.id, name: text);
              },
            ),
          ),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0.0,
            horizontal: 20.0,
          ),
          horizontalTitleGap: 10.0,
          minLeadingWidth: 0.0,
          minVerticalPadding: 0.0,
          visualDensity: const VisualDensity(vertical: -4.0),
          onTap: () {
            mainViewNavigatorKey.currentState!.pushReplacementNamed(
              MainViewRoutes.textEditor,
              arguments: <dynamic>[file, null],
            );
          },
          onLongPress: () {},
        ),
        file.codingVersions.observe((versions) {
          return Column(
            children: versions.map((version) {
              return ListTile(
                leading: Icon(
                  Icons.account_tree,
                  color: Theme.of(context).primaryIconTheme.color,
                  size: 14.0,
                ),
                title: version.name.observe((name) {
                  return TextEditable(
                    text: name,
                    style: Theme.of(context).primaryTextTheme.bodyText2,
                    edited: (text) {
                      ProjectService()
                          .updateCodingVersion(version.id, name: text);
                    },
                  );
                }),
                dense: true,
                contentPadding: const EdgeInsets.only(left: 40.0),
                horizontalTitleGap: 10.0,
                minLeadingWidth: 0.0,
                minVerticalPadding: 0.0,
                visualDensity: const VisualDensity(vertical: -4.0),
                onTap: () {
                  mainViewNavigatorKey.currentState!.pushReplacementNamed(
                    MainViewRoutes.codingEditor,
                    arguments: version,
                  );
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
