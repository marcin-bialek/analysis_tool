import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdamono/constants/keys.dart';
import 'package:qdamono/constants/routes.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/providers/visual/side_menu.dart';
import 'package:qdamono/services/project/project_service.dart';
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
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: const Text('Notatki'),
            ),
            const Spacer(),
            IconButton(
              onPressed: _projectService.addEmptyNote,
              icon: const Icon(Icons.add),
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
                itemBuilder: (context, index) =>
                    DraggableNote(note: notes[index]),
              );
            });
          }),
        ),
      ],
    );
  }
}

class DraggableNote extends ConsumerWidget {
  final Note note;
  const DraggableNote({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sideMenuWidth = ref.watch(sideMenuWidthProvider);

    return Draggable(
      rootOverlay: true,
      data: note,
      feedback: Material(
        elevation: 2.0,
        child: SizedBox(
          width: sideMenuWidth,
          height: 30.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: _SideMenuNotesItem(note: note),
          ),
        ),
      ),
      child: _SideMenuNotesItem(note: note),
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
      padding: const EdgeInsets.all(5.0),
      child: TextButton(
        child: Align(
          alignment: Alignment.centerLeft,
          child: note.title.observe((title) {
            return Text(
              note.title.value,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
        onPressed: () {
          mainViewNavigatorKey.currentState!.pushReplacementNamed(
            MainViewRoutePaths.note,
            arguments: note,
          );
        },
      ),
    );
  }
}
