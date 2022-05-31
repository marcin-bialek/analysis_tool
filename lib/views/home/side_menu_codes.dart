import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/views/dialogs.dart' show showDialogRemoveCode;
import 'package:analysis_tool/views/editable_text.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class SideMenuCodes extends StatefulWidget {
  const SideMenuCodes({Key? key}) : super(key: key);

  @override
  State<SideMenuCodes> createState() => _SideMenuCodesState();
}

class _SideMenuCodesState extends State<SideMenuCodes> {
  final _projectService = ProjectService();

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
            IconButton(
              onPressed: () {
                mainViewNavigatorKey.currentState!
                    .pushReplacementNamed(MainViewRoutes.codeStats);
              },
              icon: const Icon(
                Icons.article,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Expanded(
          child: _projectService.project.observe((project) {
            if (project == null) {
              return Container();
            }
            return project.codes.observe((value) {
              final codes = value.where((c) => c.parentId == null).toList();
              return ListView.builder(
                itemCount: codes.length,
                itemBuilder: (context, index) {
                  final code = codes[index];
                  return _SideMenuCodesItem(code: code);
                },
              );
            });
          }),
        ),
      ],
    );
  }
}

class _SideMenuCodesItem extends StatefulWidget {
  final Code code;
  final bool isChild;

  const _SideMenuCodesItem({
    Key? key,
    required this.code,
    this.isChild = false,
  }) : super(key: key);

  @override
  State<_SideMenuCodesItem> createState() => _SideMenuCodesItemState();
}

class _SideMenuCodesItemState extends State<_SideMenuCodesItem> {
  final _projectService = ProjectService();
  bool _isExpanded = false;
  bool _showChildren = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: widget.code.color.observe(
              (color) => Icon(
                Icons.circle,
                color: color,
                size: 20.0,
              ),
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          title: widget.code.name.observe(
            (name) => TextEditable(
              text: name,
              style: const TextStyle(color: Colors.white),
              edited: (text) {
                widget.code.name.value = text;
                _projectService.updatedCode(widget.code);
              },
            ),
          ),
          trailing: IconButton(
            icon: widget.code.color.observe(
              (color) => Icon(
                Icons.check,
                color: color,
              ),
            ),
            onPressed: () {
              _projectService.sendCodeRequest(widget.code);
            },
          ),
          onTap: () {
            setState(() {
              _showChildren = !_showChildren;
            });
          },
        ),
        if (_isExpanded) ...[
          widget.code.color.observe(
            (color) => ColorPicker(
              color: color,
              pickersEnabled: const {
                ColorPickerType.accent: false,
              },
              onColorChanged: (color) {
                widget.code.color.value = color;
                _projectService.updatedCode(widget.code);
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
          ),
          if (!widget.isChild)
            TextButton(
              child: const Text('Dodaj podkod'),
              onPressed: () {
                _projectService.addCode(parent: widget.code);
              },
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
        widget.code.children.observe((children) {
          if (_showChildren) {
            return Container(
              padding: const EdgeInsets.only(left: 30.0),
              child: Column(
                children: children.map((child) {
                  return _SideMenuCodesItem(code: child, isChild: true);
                }).toList(),
              ),
            );
          } else if (children.isNotEmpty) {
            return TextButton(
              onPressed: () {
                setState(() {
                  _showChildren = true;
                });
              },
              child: const Text('...'),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }
}
