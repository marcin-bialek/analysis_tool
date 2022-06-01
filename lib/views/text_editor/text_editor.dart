import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/views/dialogs.dart' show showDialogRemoveTextFile;
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TextEditor extends StatefulWidget {
  final TextFile file;
  final int? line;

  const TextEditor({
    Key? key,
    required this.file,
    this.line,
  }) : super(key: key);

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  ItemScrollController? textScrollController;
  TextEditingController? editorController;
  final textLines = <String>[];
  bool editing = false;
  bool edited = false;

  @override
  void initState() {
    super.initState();
    textLines.addAll(widget.file.textLines.value.map((e) => e.text));
    editorController = TextEditingController();
    textScrollController = ItemScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.line != null) {
        textScrollController?.scrollTo(
          index: widget.line!,
          duration: const Duration(microseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    editorController?.dispose();
    super.dispose();
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
                widget.file.name.observe((name) {
                  return Text(
                    name,
                    style:
                        Theme.of(context).primaryTextTheme.bodyText2!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  );
                }),
                const Spacer(),
                Switch(
                  value: editing,
                  onChanged: _switchEditing,
                ),
                Text(
                  'Edycja',
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
                const SizedBox(width: 20.0),
                if (!editing &&
                    edited &&
                    widget.file.codingVersions.value.isEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Zapisz'),
                    onPressed: () {
                      ProjectService().updateTextFile(
                        widget.file.id,
                        rawText: textLines.join('\n'),
                      );
                      setState(() {
                        edited = false;
                      });
                    },
                  ),
                if (!editing && edited)
                  TextButton.icon(
                    icon: const Icon(Icons.save_as),
                    label: const Text('Zapisz jako nowy'),
                    onPressed: () {
                      final textFile = TextFile.withId(
                        name: '${widget.file.name.value} (edytowany)',
                        rawText: textLines.join('\n'),
                      );
                      ProjectService().addTextFile(textFile);
                      mainViewNavigatorKey.currentState!.pushReplacementNamed(
                        MainViewRoutes.textEditor,
                        arguments: [textFile, null],
                      );
                    },
                  ),
                if (!editing)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Dodaj kodowanie'),
                    onPressed: () {
                      ProjectService().addCodingVersion(widget.file);
                    },
                  ),
                TextButton.icon(
                  icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
                  label: Text(
                    'Usuń plik',
                    style:
                        Theme.of(context).primaryTextTheme.bodyText2!.copyWith(
                              color: Theme.of(context).errorColor,
                            ),
                  ),
                  onPressed: _removeTextFile,
                ),
              ],
            ),
          ),
        ),
        if (!editing)
          Expanded(
            child: Container(
              color: Theme.of(context).canvasColor,
              child: ScrollablePositionedList.separated(
                itemCount: textLines.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Container(
                        width: 50.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          textLines[index],
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      const SizedBox(width: 50.0),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemScrollController: textScrollController,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        if (editing)
          Expanded(
            child: Container(
              color: Theme.of(context).canvasColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 50.0,
                vertical: 10.0,
              ),
              child: TextField(
                controller: editorController,
                style: Theme.of(context).textTheme.bodyText2,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                maxLines: null,
                onChanged: (_) {
                  setState(() {
                    edited = true;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  void _switchEditing(bool value) {
    setState(() {
      if (value) {
        editorController!.text = textLines.join('\n\n');
      } else {
        textLines.clear();
        textLines.addAll(editorController!.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty));
      }
      editing = value;
    });
  }

  void _removeTextFile() async {
    final result =
        await showDialogRemoveTextFile(context: context, textFile: widget.file);
    if (result == true) {
      ProjectService().removeTextFile(widget.file);
      await mainViewNavigatorKey.currentState!
          .pushReplacementNamed(MainViewRoutes.none);
    }
  }
}
