import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:flutter/material.dart';

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required Map<String, T> actions,
}) {
  return showDialog<T?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        backgroundColor: Theme.of(context).canvasColor,
        titleTextStyle:
            Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 20.0),
        contentTextStyle: Theme.of(context).textTheme.bodyText2,
        actions: actions.keys.map((k) {
          final v = actions[k];
          return TextButton(
            onPressed: () {
              Navigator.of(context).pop<T>(v);
            },
            child: Text(k),
          );
        }).toList(),
      );
    },
  );
}

Future<bool?> showDialogSaveProject({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Zapisywanie projektu',
    content: const Text('Czy zapisać obecny projekt?'),
    actions: {
      'Tak': true,
      'Nie': false,
    },
  );
}

Future<bool?> showDialogRemoveTextFile({
  required BuildContext context,
  required TextFile textFile,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Usuwanie pliku',
    content: Text('Czy usunąć plik ${textFile.name.value}? '
        'Kodowania wszystkich użytkowników również zostaną usunięte.'),
    actions: {
      'Tak': true,
      'Nie': false,
    },
  );
}

Future<bool?> showDialogRemoveTextCodingVersion({
  required BuildContext context,
  required TextCodingVersion codingVersion,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Usuwanie kodowania',
    content: Text('Czy usunąć kodowanie ${codingVersion.name.value}?'),
    actions: {
      'Tak': true,
      'Nie': false,
    },
  );
}

Future<bool?> showDialogRemoveCode({
  required BuildContext context,
  required Code code,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Usuwanie kodu',
    content: Text(code.children.value.isEmpty
        ? 'Czy usunąć kod ${code.name.value}?'
        : 'Czy usunąć kod ${code.name.value} i wszystkie jego podkody?'),
    actions: {
      'Tak': true,
      'Nie': false,
    },
  );
}

Future<bool?> showDialogRemoveNote({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Usuwanie notatki',
    content: const Text('Czy usunąć notatkę?'),
    actions: {
      'Tak': true,
      'Nie': false,
    },
  );
}

Future<bool?> showDialogCouldNotConnect({
  required BuildContext context,
  required String address,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Błąd połączenia',
    content: Text('Nie udało się połączyć z serwerem $address'),
    actions: {
      'Ok': true,
    },
  );
}

Future<bool?> showDialogConnectionInfo({
  required BuildContext context,
  required String address,
  required String passcode,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Połączono',
    content: Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(children: [
          const TableCell(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Adres:'),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SelectableText(address),
            ),
          ),
        ]),
        TableRow(children: [
          const TableCell(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Kod projektu:'),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SelectableText(passcode),
            ),
          ),
        ]),
      ],
    ),
    actions: {
      'Ok': true,
    },
  );
}
