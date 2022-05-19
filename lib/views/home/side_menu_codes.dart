import 'dart:async';

import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/views/dialogs.dart' show showDialogRemoveCode;
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class SideMenuCodes extends StatefulWidget {
  const SideMenuCodes({Key? key}) : super(key: key);

  @override
  State<SideMenuCodes> createState() => _SideMenuCodesState();
}

class _SideMenuCodesState extends State<SideMenuCodes> {
  final _projectService = ProjectService();
  final _tileOpenedStream = StreamController<int>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 20.0),
            const Text(
              'Kody',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: _projectService.addCode,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<Code>>(
            stream: _projectService.codesStream,
            initialData: const [],
            builder: (context, snap) {
              switch (snap.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return ListView.builder(
                    itemCount: snap.data!.length,
                    itemBuilder: (context, index) {
                      final code = snap.data![index];
                      return _SideMenuCodesItem(
                        code: code,
                        index: index,
                        tileOpenedStream: _tileOpenedStream.stream,
                        onOpen: () {
                          _tileOpenedStream.add(index);
                        },
                      );
                    },
                  );
                default:
                  return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SideMenuCodesItem extends StatefulWidget {
  final Code code;
  final int index;
  final Stream<int>? tileOpenedStream;
  final void Function()? onOpen;

  const _SideMenuCodesItem({
    Key? key,
    required this.code,
    required this.index,
    this.tileOpenedStream,
    this.onOpen,
  }) : super(key: key);

  @override
  State<_SideMenuCodesItem> createState() => _SideMenuCodesItemState();
}

class _SideMenuCodesItemState extends State<_SideMenuCodesItem> {
  final _projectService = ProjectService();
  bool _isExpanded = false;
  StreamSubscription<int>? _tileOpenedStreamSubscription;

  @override
  void initState() {
    super.initState();
    _tileOpenedStreamSubscription = widget.tileOpenedStream?.listen((index) {
      if (index != widget.index) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tileOpenedStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: Icon(
              Icons.circle,
              color: widget.code.color,
              size: 20.0,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded) {
                widget.onOpen?.call();
              }
            },
          ),
          title: Text(
            widget.code.name,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.check,
            color: widget.code.color,
          ),
        ),
        if (_isExpanded) ...[
          ColorPicker(
            color: widget.code.color,
            pickersEnabled: const {
              ColorPickerType.accent: false,
            },
            onColorChanged: (color) {
              _projectService.updateCode(widget.code, color: color);
            },
            borderRadius: 15.0,
            height: 30.0,
            width: 30.0,
            heading: const Text(
              'Kolor',
              style: TextStyle(color: Colors.white),
            ),
            subheading: const Text(
              'Odcień',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            child: const Text('Usuń kod'),
            onPressed: () async {
              final result = await showDialogRemoveCode(
                context: context,
                code: widget.code,
              );
              if (result == true) {
                setState(() {
                  _isExpanded = false;
                });
                _projectService.removeCode(widget.code);
              }
            },
          ),
        ],
      ],
    );
  }
}
