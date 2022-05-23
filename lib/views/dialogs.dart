import 'package:analysis_tool/models/code.dart';
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

Future<bool?> showDialogRemoveCode({
  required BuildContext context,
  required Code code,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Usuwanie kodu',
    content: Text('Czy usunąć kod ${code.name}?'),
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
