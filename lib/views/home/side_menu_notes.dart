import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:flutter/material.dart';

class SideMenuNotes extends StatefulWidget {
  const SideMenuNotes({Key? key}) : super(key: key);

  @override
  State<SideMenuNotes> createState() => _SideMenuNotesState();
}

class _SideMenuNotesState extends State<SideMenuNotes> {
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
              'Notatki',
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
            const Spacer(),
            IconButton(
              onPressed: _projectService.addEmptyNote,
              icon: Icon(
                Icons.add,
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ),
          ],
        ),
        Expanded(
          child: _projectService.project.observe((project) {
            if (project == null) {
              return Container();
            }
            return project.notes.observe((value) {
              final notes = value.toList();
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Draggable(
                    rootOverlay: true,
                    data: notes[index],
                    feedback: Material(
                      child: Container(
                        width: 300.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                        ),
                        child: _SideMenuNotesItem(note: notes[index]),
                      ),
                    ),
                    child: _SideMenuNotesItem(note: notes[index]),
                  );
                },
              );
            });
          }),
        ),
      ],
    );
  }
}

class _SideMenuNotesItem extends StatelessWidget {
  final Note note;

  const _SideMenuNotesItem({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      color: Theme.of(context).primaryColor,
      child: TextButton(
        child: Align(
          alignment: Alignment.centerLeft,
          child: note.title.observe((title) {
            return Text(
              note.title.value,
              style: Theme.of(context).primaryTextTheme.bodyText2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
        onPressed: () {
          mainViewNavigatorKey.currentState!.pushReplacementNamed(
            MainViewRoutes.note,
            arguments: note,
          );
        },
      ),
    );
  }
}
