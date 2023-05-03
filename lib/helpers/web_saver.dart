// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

Future<void> save(String filename, String data) async {
  final blob = Blob([data], 'text/plain', 'native');
  final a = AnchorElement(
    href: Url.createObjectUrlFromBlob(blob).toString(),
  );
  a.setAttribute('download', filename);
  a.click();
}
