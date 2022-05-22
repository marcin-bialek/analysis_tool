import 'dart:async';
import 'dart:math';

import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/text_coding.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
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
                widget.codingVersion.name.observe((name) {
                  return Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                const Spacer(),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color.fromARGB(0xff, 0xee, 0xee, 0xee),
            child: widget.codingVersion.codingLines.observe((codingLines) {
              return ListView.separated(
                key: UniqueKey(),
                itemCount: codingLines.length,
                itemBuilder: (context, index) {
                  final codingLine = codingLines[index];
                  return _CodingEditorLine(
                    codingVersion: widget.codingVersion,
                    codingLine: codingLine,
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CodingEditorLine extends StatefulWidget {
  final TextCodingVersion codingVersion;
  final TextCodingLine codingLine;

  const _CodingEditorLine({
    Key? key,
    required this.codingVersion,
    required this.codingLine,
  }) : super(key: key);

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
          child: Text('${widget.codingLine.textLine.index + 1}'),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: widget.codingLine.codings.observe((codings) {
              return SelectableText.rich(
                TextSpan(
                  children: _makeSpans(
                    widget.codingLine.textLine.text,
                    widget.codingLine.textLine.offset,
                    codings,
                  ),
                ),
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
              );
            }),
          ),
        ),
        Container(
          width: 250.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: widget.codingLine.codings.observe((codings) {
            return Wrap(
              spacing: 2.0,
              runSpacing: 2.0,
              children: codings.map((c) {
                return _CodingButton(coding: c);
              }).toList(),
            );
          }),
        ),
      ],
    );
  }

  List<InlineSpan> _makeSpans(
    String text,
    int offset,
    Iterable<TextCoding> codings,
  ) {
    if (codings.isEmpty) {
      return [TextSpan(text: text)];
    }
    final List<_CodingMark> marks = [];
    for (final c in codings) {
      marks.add(_CodingMark(_CodingMarkType.start, c.start - offset, c.code));
      marks.add(_CodingMark(_CodingMarkType.end, c.end - offset, c.code));
    }
    marks.sort((a, b) => a.offset.compareTo(b.offset));
    marks.add(_CodingMark(
      _CodingMarkType.end,
      text.length,
      Code.withId(name: '', color: Colors.white),
    ));
    List<InlineSpan> spans = [];
    Set<Code> currentCodes = {};
    for (int i = 0, j = 0, a = 0; i <= text.length && j < marks.length; i++) {
      if (i == marks[j].offset) {
        if (currentCodes.isNotEmpty) {
          final v =
              currentCodes.fold<int>(0, (p, c) => p + c.color.value.value) /
                  currentCodes.length;
          spans.add(
            TextSpan(
              text: text.substring(a, i),
              style: TextStyle(backgroundColor: Color(v.toInt())),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: text.substring(a, i),
            ),
          );
        }
        while (j < marks.length && i == marks[j].offset) {
          if (marks[j].type == _CodingMarkType.start) {
            currentCodes.add(marks[j].code);
          } else {
            currentCodes.remove(marks[j].code);
          }
          j += 1;
        }
        a = i;
      }
    }
    return spans;
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
    final nameText = coding.code.name.observe((name) {
      return Text(
        name,
        style: const TextStyle(color: Colors.black),
        overflow: TextOverflow.ellipsis,
      );
    });
    return coding.code.color.observe((color) {
      return Container(
        decoration: BoxDecoration(
          color: enabled ? color : Colors.grey,
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
              child: nameText,
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
    });
  }
}

class _CodingMark {
  final _CodingMarkType type;
  final int offset;
  final Code code;

  _CodingMark(this.type, this.offset, this.code);

  @override
  String toString() {
    if (type == _CodingMarkType.start) {
      return '_CodingMark: start, $offset';
    }
    return '_CodingMark: end, $offset';
  }
}

enum _CodingMarkType {
  start,
  end;
}
