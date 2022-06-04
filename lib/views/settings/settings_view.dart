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
  TextEditingController? menuFontSizeController;
  TextEditingController? editorFontSizeController;
  TextEditingController? usernameController;

  @override
  void initState() {
    super.initState();
    menuFontSizeController = TextEditingController(
        text: settings.fontSizes.value.menuFontSize.toString());
    editorFontSizeController = TextEditingController(
        text: settings.fontSizes.value.editorFontSize.toString());
    usernameController = TextEditingController(text: settings.username.value);
  }

  @override
  void dispose() {
    menuFontSizeController?.dispose();
    editorFontSizeController?.dispose();
    usernameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.3),
          1: FlexColumnWidth(0.7),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Rozmiar czcionki menu:',
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
              ),
              TableCell(
                child: TextField(
                  controller: menuFontSizeController,
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onEditingComplete: () {
                    final size = int.tryParse(menuFontSizeController!.text);
                    if (size != null) {
                      SettingsService().fontSizes.value.menuFontSize = size;
                      SettingsService().fontSizes.notify();
                    }
                  },
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Rozmiar czcionki edytora tekstu:',
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
              ),
              TableCell(
                child: TextField(
                  controller: editorFontSizeController,
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onEditingComplete: () {
                    final size = int.tryParse(editorFontSizeController!.text);
                    if (size != null) {
                      SettingsService().fontSizes.value.editorFontSize = size;
                      SettingsService().fontSizes.notify();
                    }
                  },
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Nazwa użytkownika:',
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
              ),
              TableCell(
                child: TextField(
                  controller: usernameController,
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  onEditingComplete: () {
                    final username = usernameController!.text;
                    if (username.isNotEmpty) {
                      SettingsService().username.value = username;
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
