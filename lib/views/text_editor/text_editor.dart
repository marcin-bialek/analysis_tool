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
  ItemScrollController? _textScrollController;

  @override
  void initState() {
    super.initState();
    _textScrollController = ItemScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.line != null) {
        _textScrollController?.scrollTo(
          index: widget.line!,
          duration: const Duration(microseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40.0,
          color: const Color.fromARGB(255, 51, 51, 51),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                widget.file.name.observe((name) {
                  return Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj kodowanie'),
                  onPressed: () {
                    ProjectService().addCodingVersion(widget.file);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Usuń plik',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: _removeTextFile,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color.fromARGB(0xff, 0xee, 0xee, 0xee),
            child: ScrollablePositionedList.separated(
              itemCount: widget.file.textLines.value.length,
              itemBuilder: (context, index) {
                final line = widget.file.textLines.value[index];
                return Row(
                  children: [
                    Container(
                      width: 50.0,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('${index + 1}'),
                    ),
                    Expanded(
                      child: Text(
                        line.text,
                        softWrap: true,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemScrollController: _textScrollController,
            ),
          ),
        ),
      ],
    );
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
