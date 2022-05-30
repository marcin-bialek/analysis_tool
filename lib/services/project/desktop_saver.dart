import 'dart:io';

Future<void> save(String filename, String data) async {
  await File(filename).writeAsString(data);
}
