import 'package:qdamono/services/settings/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _TextFieldRow(
              settingName: 'Rozmiar czcionki menu',
              initialValue: settings.fontSizes.value.menuFontSize.toString(),
              onChange: (value) {
                final size = int.tryParse(value);
                if (size != null) {
                  SettingsService().fontSizes.value.menuFontSize = size;
                  SettingsService().fontSizes.notify();
                }
              },
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
            _TextFieldRow(
              settingName: 'Rozmiar czcionki edytora tekstu',
              initialValue: settings.fontSizes.value.editorFontSize.toString(),
              onChange: (value) {
                final size = int.tryParse(value);
                if (size != null) {
                  SettingsService().fontSizes.value.editorFontSize = size;
                  SettingsService().fontSizes.notify();
                }
              },
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
            _TextFieldRow(
              settingName: 'Nazwa użytkownika',
              initialValue: settings.username.value,
              onChange: (value) {
                if (value.isNotEmpty) {
                  SettingsService().username.value = value;
                }
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _TextFieldRow extends StatefulWidget {
  final String settingName;
  final String? initialValue;
  final void Function(String)? onChange;
  final List<TextInputFormatter>? formatters;

  const _TextFieldRow({
    Key? key,
    required this.settingName,
    this.initialValue,
    this.onChange,
    this.formatters,
  }) : super(key: key);

  @override
  State<_TextFieldRow> createState() => _TextFieldRowState();
}

class _TextFieldRowState extends State<_TextFieldRow> {
  TextEditingController? textController;
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialValue);
    focusNode = FocusNode();
    focusNode?.addListener(() {
      if (focusNode?.hasFocus == false) {
        FocusManager.instance.primaryFocus?.unfocus();
        widget.onChange?.call(textController?.text ?? '');
      }
    });
  }

  @override
  void dispose() {
    textController?.dispose();
    focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '${widget.settingName}:',
            style: Theme.of(context).primaryTextTheme.bodyText2,
          ),
        ),
        Expanded(
          flex: 7,
          child: TextField(
            controller: textController,
            focusNode: focusNode,
            style: Theme.of(context).primaryTextTheme.bodyText2,
            onEditingComplete: () {
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onChange?.call(textController?.text ?? '');
            },
            inputFormatters: widget.formatters,
          ),
        ),
      ],
    );
  }
}
