import 'dart:async';
import 'dart:math';

import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/text_coding.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service.dart';
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
  Code? enabledCode;
  TextCoding? enabledCoding;

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
            // child: ListView.separated(
            //   key: UniqueKey(),
            //   itemCount: widget.codingVersion.file.textLines.length,
            //   itemBuilder: (context, index) {
            //     final text = widget.codingVersion.file.textLines[index];
            //     return _CodingEditorLine(
            //       codingVersion: widget.codingVersion,
            //       index: index,
            //       text: text.text,
            //     );
            //   },
            //   separatorBuilder: (context, index) {
            //     return const Divider();
            //   },
            // ),
            child: StreamBuilder<List<TextCodingLine>>(
              stream: widget.codingVersion.codingLinesStream,
              builder: (context, snap) {
                switch (snap.connectionState) {
                  case ConnectionState.active:
                    return ListView.separated(
                      key: UniqueKey(),
                      itemCount: snap.data!.length,
                      itemBuilder: (context, index) {
                        final codingLine = snap.data![index];
                        return _CodingEditorLine(
                          codingVersion: widget.codingVersion,
                          codingLine: codingLine,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    );
                  default:
                    return Container();
                }
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
  final TextCodingLine codingLine;
  late final TextLine textLine;

  _CodingEditorLine({
    Key? key,
    required this.codingVersion,
    required this.codingLine,
  }) : super(key: key) {
    textLine = codingVersion.file.textLines[codingLine.index];
  }

  @override
  State<_CodingEditorLine> createState() => _CodingEditorLineState();
}

class _CodingEditorLineState extends State<_CodingEditorLine> {
  int? _selectionStart;
  int? _selectionEnd;
  StreamSubscription<Code>? _codeRequestSubscription;

  @override
  void initState() {
    super.initState();
    _codeRequestSubscription = ProjectService().codeRequestStream.listen(
      (code) {
        if (_selectionStart != null && _selectionEnd != null) {
          widget.codingVersion.addCoding(
            widget.codingLine,
            code,
            _selectionStart!,
            _selectionEnd! - _selectionStart!,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _codeRequestSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text('${widget.textLine.index + 1}'),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SelectableText.rich(
              TextSpan(children: [
                TextSpan(
                  text: widget.textLine.text,
                ),
              ]),
              maxLines: null,
              style: const TextStyle(fontSize: 15.0),
              onSelectionChanged: (selection, _) {
                if (selection.baseOffset != selection.extentOffset) {
                  _selectionStart =
                      min(selection.baseOffset, selection.extentOffset);
                  _selectionEnd =
                      max(selection.baseOffset, selection.extentOffset);
                } else {
                  _selectionStart = null;
                  _selectionEnd = null;
                }
              },
            ),
          ),
        ),
        Container(
          width: 250.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Wrap(
            spacing: 2.0,
            runSpacing: 2.0,
            children: widget.codingLine.codings.map((c) {
              return _CodingButton(coding: c);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CodingButton extends StatelessWidget {
  final TextCoding coding;
  final bool enabled;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const _CodingButton({
    Key? key,
    required this.coding,
    this.enabled = true,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? coding.code.color : Colors.grey,
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onPressed,
            onLongPress: onLongPress,
            child: Text(
              coding.code.name,
              style: const TextStyle(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.remove_circle,
              size: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}
