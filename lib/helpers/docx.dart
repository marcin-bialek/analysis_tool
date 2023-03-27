import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:qdamono/services/project/project_service_exceptions.dart';
import 'package:xml/xml.dart';

String getTextFromDocx(Uint8List bytes) {
  try {
    final archive = ZipDecoder().decodeBytes(bytes);
    final document = archive.files.firstWhere(
      (e) => e.name == 'word/document.xml',
    );
    final stream = OutputStream();
    document.decompress(stream);
    final data = const Utf8Decoder().convert(stream.getBytes());
    final xml = XmlDocument.parse(data);
    return xml.findAllElements('w:p').map((p) {
      return p.findAllElements('w:t').map((t) => t.text).join();
    }).join('\n');
  } catch (e) {
    if (kDebugMode) {
      print('Docs: $e');
    }
    throw UnsupportedFileError();
  }
}
