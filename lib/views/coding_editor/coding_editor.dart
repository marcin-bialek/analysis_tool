import 'dart:async';
import 'dart:math';

import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/models/observable.dart';
import 'package:analysis_tool/models/text_coding.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/views/dialogs.dart';
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

class _EnabledCoding {
  TextCoding? coding;
  bool entireCode;

  _EnabledCoding([this.coding, this.entireCode = false]);

  bool shouldEnable(TextCoding coding) {
    return this.coding == null ||
        (entireCode ? this.coding!.code == coding.code : this.coding == coding);
  }
}

class _CodingEditorState extends State<CodingEditor> {
  final _selectedLine = Observable<_CodingEditorLine?>(null);
  final _enabledCoding = Observable(_EnabledCoding());

  @override
  void initState() {
    super.initState();
    _enabledCoding.addListener(_onEnabledCodingChange);
  }

  @override
  void dispose() {
    _enabledCoding.removeListener(_onEnabledCodingChange);
    super.dispose();
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
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Usuń kodowanie',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: _removeCodingVersion,
                ),
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
                  return DragTarget<Note>(
                    builder: (context, candidateData, rejectedData) {
                      return _CodingEditorLine(
                        codingVersion: widget.codingVersion,
                        codingLine: codingLine,
                        enabledCoding: _enabledCoding,
                        selectedLine: _selectedLine,
                        backgroundColor:
                            candidateData.isNotEmpty ? Colors.white54 : null,
                      );
                    },
                    onAccept: (note) {
                      ProjectService().addNoteToCodingLine(
                        widget.codingVersion,
                        codingLine.textLine.index,
                        note,
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                padding: const EdgeInsets.symmetric(vertical: 10.0),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _onEnabledCodingChange(_EnabledCoding enabledCoding) {
    for (final codingLine in widget.codingVersion.codingLines.value) {
      codingLine.codings.notify();
    }
  }

  void _removeCodingVersion() async {
    final result = await showDialogRemoveTextCodingVersion(
      context: context,
      codingVersion: widget.codingVersion,
    );
    if (result == true) {
      ProjectService().removeCodingVersion(widget.codingVersion);
      await mainViewNavigatorKey.currentState!
          .pushReplacementNamed(MainViewRoutes.none);
    }
  }
}

class _CodingEditorLine extends StatefulWidget {
  final TextCodingVersion codingVersion;
  final TextCodingLine codingLine;
  final Observable<_EnabledCoding> enabledCoding;
  final Observable<_CodingEditorLine?> selectedLine;
  final Color? backgroundColor;

  const _CodingEditorLine({
    Key? key,
    required this.codingVersion,
    required this.codingLine,
    required this.enabledCoding,
    required this.selectedLine,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<_CodingEditorLine> createState() => _CodingEditorLineState();
}

class _CodingEditorLineState extends State<_CodingEditorLine> {
  Key _selectableTextKey = UniqueKey();
  int? _selectionStart;
  int? _selectionEnd;
  StreamSubscription<Code>? _codeRequestSubscription;
  StreamSubscription<_CodingEditorLine?>? _selectedLineSubscription;

  @override
  void initState() {
    super.initState();
    _codeRequestSubscription = ProjectService().codeRequestStream.listen(
      (code) {
        if (_selectionStart != null && _selectionEnd != null) {
          ProjectService().addNewCoding(
            widget.codingVersion,
            widget.codingLine,
            code,
            _selectionStart!,
            _selectionEnd! - _selectionStart!,
          );
          setState(() {
            _selectableTextKey = UniqueKey();
          });
          _selectionStart = null;
          _selectionEnd = null;
        }
      },
    );
    _selectedLineSubscription = widget.selectedLine.stream.listen((line) {
      if (line != widget && _selectionStart != null && _selectionEnd != null) {
        setState(() {
          _selectableTextKey = UniqueKey();
        });
        _selectionStart = null;
        _selectionEnd = null;
      }
    });
  }

  @override
  void dispose() {
    _codeRequestSubscription?.cancel();
    _selectedLineSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Row(
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
                return TextSelectionTheme(
                  data: const TextSelectionThemeData(
                    selectionColor: Colors.red,
                  ),
                  child: SelectableText.rich(
                    TextSpan(
                      children: _makeSpans(
                        widget.codingLine.textLine.text,
                        widget.codingLine.textLine.offset,
                        codings,
                      ),
                    ),
                    key: _selectableTextKey,
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
                    onTap: () {
                      widget.selectedLine.value = widget;
                    },
                  ),
                );
              }),
            ),
          ),
          Container(
            width: 250.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: widget.codingLine.notes.observe((notes) {
              return widget.codingLine.codings.observe((codings) {
                return Wrap(
                  spacing: 2.0,
                  runSpacing: 2.0,
                  children: [
                    ...codings.map((c) {
                      return _CodingButton(
                        key: UniqueKey(),
                        coding: c,
                        enabledCoding: widget.enabledCoding,
                        onRemove: () {
                          ProjectService()
                              .removeCoding(widget.codingVersion, c);
                        },
                      );
                    }),
                    ...notes.map((n) {
                      return _NoteButton(
                        note: n,
                        onRemove: () {
                          ProjectService().removeNoteFromCodingLine(
                            widget.codingVersion,
                            widget.codingLine.textLine.index,
                            n,
                          );
                        },
                      );
                    }),
                  ],
                );
              });
            }),
          ),
        ],
      ),
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
      if (widget.enabledCoding.value.shouldEnable(c)) {
        marks.add(_CodingMark(_CodingMarkType.start, c.start - offset, c.code));
        marks.add(_CodingMark(_CodingMarkType.end, c.end - offset, c.code));
      }
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
              style: TextStyle(
                backgroundColor: Color(v.toInt()).withOpacity(0.8),
              ),
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
  final Observable<_EnabledCoding> enabledCoding;
  final void Function()? onRemove;

  const _CodingButton({
    Key? key,
    required this.coding,
    required this.enabledCoding,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return coding.code.color.observe((color) {
      return enabledCoding.observe((enabledCoding) {
        return Container(
          decoration: BoxDecoration(
            color: enabledCoding.shouldEnable(coding) ? color : Colors.grey,
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () {
                    if (enabledCoding.coding != null &&
                        enabledCoding.shouldEnable(coding)) {
                      this.enabledCoding.value = _EnabledCoding();
                    } else {
                      this.enabledCoding.value = _EnabledCoding(coding, false);
                    }
                  },
                  onLongPress: () {
                    this.enabledCoding.value = _EnabledCoding(coding, true);
                  },
                  child: coding.code.name.observe((name) {
                    return Text(
                      name,
                      style: const TextStyle(color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
              ),
              IconButton(
                onPressed: onRemove,
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
    });
  }
}

class _NoteButton extends StatelessWidget {
  final Note note;
  final void Function()? onRemove;

  const _NoteButton({
    Key? key,
    required this.note,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 30, 30, 30),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: note.title.observe((title) {
              return TextButton(
                onPressed: () {
                  mainViewNavigatorKey.currentState!.pushReplacementNamed(
                    MainViewRoutes.note,
                    arguments: note,
                  );
                },
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }),
          ),
          IconButton(
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.remove_circle,
              size: 15.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
