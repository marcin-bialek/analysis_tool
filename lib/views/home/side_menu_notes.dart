import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/services/project/project_service.dart';
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
          child: StreamBuilder<List<Note>>(
            stream: _projectService.notesStream,
            initialData: const [],
            builder: (context, snap) {
              switch (snap.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return ListView.builder(
                    itemCount: snap.data!.length,
                    itemBuilder: (context, index) {
                      final note = snap.data![index];
                      return _SideMenuNotesItem(note: note);
                    },
                  );
                default:
                  return Container();
              }
            },
          ),
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
    _textController = TextEditingController(text: widget.note.text);
    _focusNode!.addListener(() {
      if (!_focusNode!.hasFocus) {
        _projectService.updateNote(widget.note, _textController!.text);
      }
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
}
