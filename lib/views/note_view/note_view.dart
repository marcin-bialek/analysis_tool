import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/views/dialogs.dart';
import 'package:flutter/material.dart';

class NoteView extends StatefulWidget {
  final Note note;

  const NoteView({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  TextEditingController? titleController;
  TextEditingController? textController;
  FocusNode? titleFocusNode;
  FocusNode? textFocusNode;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title.value);
    textController = TextEditingController(text: widget.note.text.value);
    titleFocusNode = FocusNode();
    textFocusNode = FocusNode();
    titleFocusNode!.addListener(() {
      if (!titleFocusNode!.hasFocus) {
        ProjectService().updateNote(
          widget.note.id,
          title: titleController!.text,
        );
      }
    });
    textFocusNode!.addListener(() {
      if (!textFocusNode!.hasFocus) {
        ProjectService().updateNote(
          widget.note.id,
          text: textController!.text,
        );
      }
    });
    widget.note.title.addListener(_updateTitle);
    widget.note.text.addListener(_updateText);
  }

  @override
  void dispose() {
    widget.note.title.removeListener(_updateTitle);
    widget.note.text.removeListener(_updateText);
    titleFocusNode?.dispose();
    textFocusNode?.dispose();
    titleController?.dispose();
    textController?.dispose();
    super.dispose();
  }

  void _updateTitle(String title) {
    titleController?.text = title;
  }

  void _updateText(String text) {
    textController?.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(0xff, 0xee, 0xee, 0xee),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: titleController,
                  focusNode: titleFocusNode,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.delete,
                  size: 20.0,
                  color: Colors.red,
                ),
                label: const Text(
                  'Usuń notatkę',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  final result = await showDialogRemoveNote(context: context);
                  if (result == true) {
                    mainViewNavigatorKey.currentState!
                        .pushReplacementNamed(MainViewRoutes.none);
                    ProjectService().removeNote(widget.note);
                  }
                },
              ),
            ],
          ),
          TextField(
            controller: textController,
            focusNode: textFocusNode,
            style: const TextStyle(
              fontSize: 14.0,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            maxLines: null,
          ),
        ],
      ),
    );
  }
}
