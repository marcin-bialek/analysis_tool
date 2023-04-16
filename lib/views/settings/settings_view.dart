import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qdamono/providers/settings/settings.dart';
import 'package:qdamono/providers/settings/theme.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(appThemeModeProvider);

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
              initialValue: settings.fontSizes.menuFontSize.toString(),
              onChange: (value) {
                final size = int.tryParse(value);
                if (size != null) {
                  ref.read(settingsProvider.notifier).setFontSizes(FontSizes(
                        menuFontSize: size,
                        editorFontSize: settings.fontSizes.editorFontSize,
                      ));
                }
              },
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
            _TextFieldRow(
              settingName: 'Rozmiar czcionki edytora tekstu',
              initialValue: settings.fontSizes.editorFontSize.toString(),
              onChange: (value) {
                final size = int.tryParse(value);
                if (size != null) {
                  ref.read(settingsProvider.notifier).setFontSizes(FontSizes(
                        menuFontSize: settings.fontSizes.menuFontSize,
                        editorFontSize: size,
                      ));
                }
              },
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
            _TextFieldRow(
              settingName: 'Adres serwera',
              initialValue: settings.serverAddress,
              onChange: (value) {
                if (value.isNotEmpty) {
                  ref.read(settingsProvider.notifier).setServerAddress(value);
                }
              },
            ),
            _SwitchFieldRow(
              settingName: 'Pozwalaj na połączenia przez HTTP',
              initialValue: settings.allowInsecureConnection,
              onChange: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .setAllowInsecureConnection(value);
                return value;
              },
            ),
            _SwitchFieldRow(
              settingName: 'Motyw systemowy',
              initialValue: themeMode == ThemeMode.system,
              onChange: (value) {
                ref.read(appThemeModeProvider.notifier).setSystem(value);
                return value;
              },
            ),
            _SwitchFieldRow(
              settingName: 'Motyw ciemny',
              disabled: themeMode == ThemeMode.system,
              initialValue:
                  ref.read(appThemeModeProvider.notifier).isDarkMode(),
              force: themeMode == ThemeMode.system,
              onChange: (value) {
                ref
                    .read(appThemeModeProvider.notifier)
                    .set(value ? ThemeMode.dark : ThemeMode.light);
                return value;
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SwitchFieldRow extends StatefulWidget {
  final String settingName;
  final bool? initialValue;
  final bool Function(bool)? onChange;
  final bool disabled;
  final bool force;

  const _SwitchFieldRow({
    Key? key,
    required this.settingName,
    this.initialValue,
    this.onChange,
    this.disabled = false,
    this.force = false,
  }) : super(key: key);

  @override
  State<_SwitchFieldRow> createState() => _SwitchFieldRowState();
}

class _SwitchFieldRowState extends State<_SwitchFieldRow> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue ?? false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.force && (widget.initialValue ?? false) != value) {
      setState(
        () => value = widget.initialValue ?? false,
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '${widget.settingName}:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          flex: 7,
          child: Switch(
            value: value,
            onChanged: widget.disabled
                ? null
                : (newValue) {
                    final valueToSet = widget.onChange?.call(newValue) ?? value;
                    if (valueToSet != value) {
                      setState(() {
                        value = valueToSet;
                      });
                    }
                  },
          ),
        ),
      ],
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
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          flex: 7,
          child: TextField(
            controller: textController,
            focusNode: focusNode,
            style: Theme.of(context).textTheme.bodyMedium,
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
