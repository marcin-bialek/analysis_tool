import 'dart:async';
import 'dart:math';

import 'package:qdamono/constants/keys.dart';
import 'package:qdamono/constants/routes.dart';
import 'package:qdamono/helpers/coding_view.dart';
import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/models/observable.dart';
import 'package:qdamono/models/text_coding.dart';
import 'package:qdamono/models/text_coding_version.dart';
import 'package:qdamono/services/project/project_service.dart';
import 'package:qdamono/views/dialogs.dart';
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
  final selectedLines = Observable(<_CodingEditorLine>{});
  final lineWithSelection = Observable<_CodingEditorLine?>(null);
  final enabledCoding = Observable(EnabledCoding());

  @override
  void initState() {
    super.initState();
    enabledCoding.addListener(_onEnabledCodingChange);
  }

  @override
  void dispose() {
    enabledCoding.removeListener(_onEnabledCodingChange);
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
                widget.codingVersion.file.name.observe((textFileName) {
                  return widget.codingVersion.name.observe((versionName) {
                    return Text(
                      '$versionName ($textFileName)',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodyText2!
                          .copyWith(fontWeight: FontWeight.bold),
                    );
                  });
                }),
                const SizedBox(width: 20),
                if (widget.codingVersion.file.codingVersions.value.length > 1)
                  DropdownButton<TextCodingVersion>(
                    style: Theme.of(context).primaryTextTheme.bodyText2,
                    dropdownColor: Theme.of(context).primaryColorLight,
                    hint: const Text('Porównaj z'),
                    items: widget.codingVersion.file.codingVersions.value
                        .where((v) => v != widget.codingVersion)
                        .map((version) {
                      return DropdownMenuItem(
                        value: version,
                        child: Text(version.name.value),
                      );
                    }).toList(),
                    onChanged: (version) {
                      mainViewNavigatorKey.currentState!.pushReplacementNamed(
                        MainViewRoutes.codingCompare,
                        arguments: [widget.codingVersion, version],
                      );
                    },
                  ),
                const Spacer(),
                TextButton.icon(
                  icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
                  label: Text(
                    'Usuń kodowanie',
                    style: Theme.of(context).primaryTextTheme.button!.copyWith(
                          color: Theme.of(context).errorColor,
                        ),
                  ),
                  onPressed: _removeCodingVersion,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).canvasColor,
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
                        enabledCoding: enabledCoding,
                        lineWithSelection: lineWithSelection,
                        selectedLines: selectedLines,
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
                  return const Divider(height: 1);
                },
                padding: const EdgeInsets.symmetric(vertical: 10.0),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _onEnabledCodingChange(EnabledCoding enabledCoding) {
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
  final Observable<EnabledCoding> enabledCoding;
  final Observable<_CodingEditorLine?> lineWithSelection;
  final Observable<Set<_CodingEditorLine>> selectedLines;
  final Color? backgroundColor;

  const _CodingEditorLine({
    Key? key,
    required this.codingVersion,
    required this.codingLine,
    required this.enabledCoding,
    required this.lineWithSelection,
    required this.selectedLines,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<_CodingEditorLine> createState() => _CodingEditorLineState();
}

class _CodingEditorLineState extends State<_CodingEditorLine> {
  Key selectableTextKey = UniqueKey();
  int? selectionStart;
  int? selectionEnd;
  StreamSubscription<Code>? codeRequestSubscription;
  StreamSubscription<_CodingEditorLine?>? selectedLineSubscription;

  @override
  void initState() {
    super.initState();
    codeRequestSubscription = ProjectService().codeRequestStream.listen(
      (code) {
        if (widget.selectedLines.value.remove(widget)) {
          ProjectService().addNewCoding(
            widget.codingVersion,
            widget.codingLine,
            code,
            0,
            widget.codingLine.textLine.text.length,
          );
          widget.selectedLines.notify();
        } else if (selectionStart != null && selectionEnd != null) {
          ProjectService().addNewCoding(
            widget.codingVersion,
            widget.codingLine,
            code,
            selectionStart!,
            selectionEnd! - selectionStart!,
          );
        }
        setState(() {
          selectableTextKey = UniqueKey();
        });
        selectionStart = null;
        selectionEnd = null;
      },
    );
    selectedLineSubscription = widget.lineWithSelection.stream.listen((line) {
      if (line != widget && selectionStart != null && selectionEnd != null) {
        setState(() {
          selectableTextKey = UniqueKey();
        });
        selectionStart = null;
        selectionEnd = null;
      }
    });
  }

  @override
  void dispose() {
    codeRequestSubscription?.cancel();
    selectedLineSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GestureDetector(
              onTap: () {
                if (!widget.selectedLines.value.add(widget)) {
                  widget.selectedLines.value.remove(widget);
                }
                widget.selectedLines.notify();
              },
              child: Text(
                '${widget.codingLine.textLine.index + 1}',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ),
          Expanded(
            child: widget.selectedLines.observe((selectedLines) {
              return Container(
                color: selectedLines.contains(widget) ? Colors.red : null,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: widget.codingLine.codings.observe((codings) {
                  return TextSelectionTheme(
                    data: const TextSelectionThemeData(
                      selectionColor: Colors.red,
                    ),
                    child: SelectableText.rich(
                      TextSpan(
                        children: makeTextCodingSpans(
                          widget.codingLine.textLine.text,
                          widget.codingLine.textLine.offset,
                          codings,
                          [widget.enabledCoding.value],
                        ),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      key: selectableTextKey,
                      maxLines: null,
                      onSelectionChanged: (selection, _) {
                        if (selection.baseOffset != selection.extentOffset) {
                          selectionStart =
                              min(selection.baseOffset, selection.extentOffset);
                          selectionEnd =
                              max(selection.baseOffset, selection.extentOffset);
                        } else {
                          selectionStart = null;
                          selectionEnd = null;
                        }
                      },
                      onTap: () {
                        widget.lineWithSelection.value = widget;
                        widget.selectedLines.value.clear();
                        widget.selectedLines.notify();
                      },
                    ),
                  );
                }),
              );
            }),
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
}

class _CodingButton extends StatelessWidget {
  final TextCoding coding;
  final Observable<EnabledCoding> enabledCoding;
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
                      this.enabledCoding.value = EnabledCoding();
                    } else {
                      this.enabledCoding.value = EnabledCoding(coding, false);
                    }
                  },
                  onLongPress: () {
                    this.enabledCoding.value = EnabledCoding(coding, true);
                  },
                  child: coding.code.name.observe((name) {
                    return Text(
                      name,
                      style: Theme.of(context).textTheme.bodyText2,
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
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(
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
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText2!.color,
                      ),
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
