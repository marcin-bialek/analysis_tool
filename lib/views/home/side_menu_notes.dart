import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/models/server_events/event_note_update.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/services/server/server_service.dart';
import 'package:analysis_tool/views/dialogs.dart' show showDialogRemoveNote;
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
            const Text(
              'Notatki',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: _projectService.addEmptyNote,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
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
                        height: 100.0,
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

class _SideMenuNotesItem extends StatefulWidget {
  final Note note;

  const _SideMenuNotesItem({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SideMenuNotesItemState();
}

class _SideMenuNotesItemState extends State<_SideMenuNotesItem> {
  final _projectService = ProjectService();
  FocusNode? _focusNode;
  TextEditingController? _textController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textController = TextEditingController(text: widget.note.text.value);
    _focusNode!.addListener(() {
      if (!_focusNode!.hasFocus) {
        widget.note.text.value = _textController!.text;
        ServerService().sendEvent(EventNoteUpdate(
          noteId: widget.note.id,
          text: widget.note.text.value,
        ));
      }
    });
    widget.note.text.addListener(_onNoteUpdate);
  }

  @override
  void dispose() {
    widget.note.text.removeListener(_onNoteUpdate);
    _focusNode?.dispose();
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      color: const Color.fromARGB(255, 30, 30, 30),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 13.0),
              maxLines: null,
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await showDialogRemoveNote(context: context);
              if (result == true) {
                _projectService.removeNote(widget.note);
              }
            },
            icon: const Icon(
              Icons.remove_circle,
              size: 20.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _onNoteUpdate(String value) {
    _textController?.text = value;
  }
}
