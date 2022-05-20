import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:flutter/material.dart';

class CodingEditor extends StatefulWidget {
  final TextCodingVersion codingVersion;

  const CodingEditor({
    Key? key,
    required this.codingVersion,
  }) : super(key: key);

  @override
  State<CodingEditor> createState() => _CodingEditorState();
}

class _CodingEditorState extends State<CodingEditor> {
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
                  widget.codingVersion.name,
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
              key: UniqueKey(),
              itemCount: widget.codingVersion.file.textLines.length,
              itemBuilder: (context, index) {
                final text = widget.codingVersion.file.textLines[index];
                return _CodingEditorLine(
                  codingVersion: widget.codingVersion,
                  index: index,
                  text: text,
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

class _CodingEditorLine extends StatefulWidget {
  final TextCodingVersion codingVersion;
  final int index;
  final String text;

  const _CodingEditorLine({
    Key? key,
    required this.codingVersion,
    required this.index,
    required this.text,
  }) : super(key: key);

  @override
  State<_CodingEditorLine> createState() => _CodingEditorLineState();
}

class _CodingEditorLineState extends State<_CodingEditorLine> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text('${widget.index + 1}'),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SelectableText.rich(
              TextSpan(children: [
                TextSpan(
                  text: widget.text,
                ),
              ]),
              maxLines: null,
              style: const TextStyle(fontSize: 15.0),
            ),
          ),
        ),
        Container(
          width: 250.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: const Text(
            "kody",
            maxLines: null,
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
        ),
      ],
    );
  }
}
