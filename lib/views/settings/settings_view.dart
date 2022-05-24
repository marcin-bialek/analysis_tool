import 'package:analysis_tool/services/settings/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final settings = SettingsService();
  TextEditingController? fontSizeController;
  TextEditingController? usernameController;

  @override
  void initState() {
    super.initState();
    fontSizeController = TextEditingController(text: '13');
    usernameController = TextEditingController(text: settings.username);
    usernameController?.addListener(() {
      settings.username = usernameController!.text;
    });
  }

  @override
  void dispose() {
    fontSizeController?.dispose();
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
          // TableRow(
          //   children: [
          //     const TableCell(
          //       verticalAlignment: TableCellVerticalAlignment.middle,
          //       child: Text(
          //         'Rozmiar czcionki:',
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //     TableCell(
          //       child: TextField(
          //         controller: fontSizeController,
          //         style: const TextStyle(color: Colors.white, fontSize: 15.0),
          //       ),
          //     ),
          //   ],
          // ),
          TableRow(
            children: [
              const TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Nazwa użytkownika:',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TableCell(
                child: TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
