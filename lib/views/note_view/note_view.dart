import 'package:qdamono/constants/keys.dart';
import 'package:qdamono/constants/routes.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/services/project/project_service.dart';
import 'package:qdamono/views/dialogs.dart';
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
    return Column(
      children: [
        Container(
          height: 40.0,
          color: Theme.of(context).primaryColorLight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                widget.note.title.observe((title) {
                  return Text(
                    title,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .bodyText2!
                        .copyWith(fontWeight: FontWeight.bold),
                  );
                }),
                const Spacer(),
                TextButton.icon(
                  icon: Icon(
                    Icons.delete,
                    size: 20.0,
                    color: Theme.of(context).errorColor,
                  ),
                  label: Text(
                    'Usuń notatkę',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button!
                        .copyWith(color: Theme.of(context).errorColor),
                  ),
                  onPressed: () async {
                    final result = await showDialogRemoveNote(context: context);
                    if (result == true) {
                      mainViewNavigatorKey.currentState!
                          .pushReplacementNamed(MainViewRoutePaths.none);
                      ProjectService().removeNote(widget.note);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Theme.of(context).canvasColor,
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: titleController,
            focusNode: titleFocusNode,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      Theme.of(context).textTheme.bodyText2!.fontSize! * 1.3,
                ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).canvasColor,
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
            ),
            child: TextField(
              controller: textController,
              focusNode: textFocusNode,
              style: Theme.of(context).textTheme.bodyText2,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
            ),
          ),
        ),
      ],
    );
  }
}
