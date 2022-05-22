import 'package:flutter/material.dart';

class TextEditable extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final void Function(String text)? edited;

  const TextEditable({
    Key? key,
    required this.text,
    this.style,
    this.edited,
  }) : super(key: key);

  @override
  State<TextEditable> createState() => _EditableTextState();
}

class _EditableTextState extends State<TextEditable> {
  bool _editing = false;
  TextEditingController? _controller;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant TextEditable oldWidget) {
    _controller?.text = widget.text;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (value) {
        if (value == false) {
          setState(() {
            _editing = false;
          });
          widget.edited?.call(_controller!.text);
        }
      },
      child: _editing
          ? TextField(
              style: widget.style,
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            )
          : GestureDetector(
              child: Text(
                widget.text,
                style: widget.style,
              ),
              onLongPress: () {
                setState(() {
                  _editing = true;
                });
                Future.delayed(const Duration(milliseconds: 100)).then((_) {
                  _focusNode?.requestFocus();
                });
              },
            ),
    );
  }
}
