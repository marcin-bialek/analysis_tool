import 'package:analysis_tool/models/text_file.dart';
import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {
  final TextFile file;

  const TextEditor({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
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
                Text(
                  widget.file.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color.fromARGB(0xff, 0xee, 0xee, 0xee),
            child: ListView.separated(
              itemCount: widget.file.textLines.length,
              itemBuilder: (context, index) {
                final line = widget.file.textLines[index];
                return Row(
                  children: [
                    Container(
                      width: 50.0,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('${index + 1}'),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        softWrap: true,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            ),
          ),
        ),
      ],
    );
  }
}
