import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/models/text_coding_version.dart';
import 'package:qdamono/models/text_file.dart';
import 'package:qdamono/services/project/project_service.dart';

void main() {
  tearDown(() {
    // remove all text files, codes, notes, etc.
    ProjectService().closeProject();
  });

  test('ProjectService.addTextFile', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');

    service.addTextFile(textFile, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.textFiles.value.length, equals(1));
    expect(
        service.project.value!.textFiles.value.first.id, equals(textFile.id));
  });

  test('ProjectService.removeTextFile', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');

    service.addTextFile(textFile, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.textFiles.value.length, equals(1));
    service.removeTextFile(textFile, sendToServer: false);
    expect(service.project.value!.textFiles.value.length, equals(0));
  });

  test('ProjectService.updateTextFile', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');

    service.addTextFile(textFile, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.textFiles.value.length, equals(1));
    expect(service.project.value!.textFiles.value.first.name.value,
        equals('test file'));
    expect(service.project.value!.textFiles.value.first.rawText.value,
        equals('abc'));
    service.updateTextFile(textFile.id,
        name: 'new name', rawText: 'new text', sendToServer: false);
    expect(service.project.value!.textFiles.value.first.name.value,
        equals('new name'));
    expect(service.project.value!.textFiles.value.first.rawText.value,
        equals('new text'));
  });

  test('ProjectService.addCode', () {
    final service = ProjectService();
    final code = Code.withId(name: 'test', color: Colors.black);
    service.addCode(code, sendToServer: false);

    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.codes.value.length, equals(1));
    expect(service.project.value!.codes.value.first.id, equals(code.id));
  });

  test('ProjectService.removeCode', () {
    final service = ProjectService();
    final code = Code.withId(name: 'test', color: Colors.black);

    service.addCode(code, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.codes.value.length, equals(1));
    service.removeCode(code, sendToServer: false);
    expect(service.project.value!.codes.value.length, equals(0));
  });

  test('ProjectService.updateCode', () {
    final service = ProjectService();
    final code = Code.withId(name: 'test', color: Colors.black);

    service.addCode(code, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.codes.value.length, equals(1));
    expect(service.project.value!.codes.value.first.name.value, equals('test'));
    expect(service.project.value!.codes.value.first.color.value,
        equals(Colors.black));
    code.name.value = 'new name';
    code.color.value = Colors.orange;
    expect(service.project.value!.codes.value.first.name.value,
        equals('new name'));
    expect(service.project.value!.codes.value.first.color.value,
        equals(Colors.orange));
  });

  test('ProjectService.addNote', () {
    final service = ProjectService();
    final note = Note.withId(title: 'test', text: 'qwerty');

    service.addNote(note, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.notes.value.length, equals(1));
    expect(service.project.value!.notes.value.first.id, equals(note.id));
  });

  test('ProjectService.removeNote', () {
    final service = ProjectService();
    final note = Note.withId(title: 'test', text: 'qwerty');

    service.addNote(note, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.notes.value.length, equals(1));
    service.removeNote(note, sendToServer: false);
    expect(service.project.value!.notes.value.length, equals(0));
  });

  test('ProjectService.updateNote', () {
    final service = ProjectService();
    final note = Note.withId(title: 'test', text: 'qwerty');

    service.addNote(note, sendToServer: false);
    expect(service.project.value, isNot(equals(null)));
    expect(service.project.value!.notes.value.length, equals(1));
    expect(
        service.project.value!.notes.value.first.title.value, equals('test'));
    expect(
        service.project.value!.notes.value.first.text.value, equals('qwerty'));
    service.updateNote(note.id,
        title: 'new title', text: 'new text', sendToServer: false);
    expect(service.project.value!.notes.value.first.title.value,
        equals('new title'));
    expect(service.project.value!.notes.value.first.text.value,
        equals('new text'));
  });

  test('ProjectService.addNewCodingVersion', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');
    service.addTextFile(textFile, sendToServer: false);
    service.addNewCodingVersion(textFile, sendToServer: false);

    expect(service.project.value, isNot(equals(null)));
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.length,
      equals(1),
    );
  });

  test('ProjectService.removeCodingVersion', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');
    service.addTextFile(textFile, sendToServer: false);
    final codingVersion = TextCodingVersion.withId(name: 'v1', file: textFile);
    service.addCodingVersion(codingVersion, sendToServer: false);

    expect(service.project.value, isNot(equals(null)));
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.length,
      equals(1),
    );
    service.removeCodingVersion(codingVersion, sendToServer: false);
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.length,
      equals(0),
    );
  });

  test('ProjectService.updateCodingVersion', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');
    service.addTextFile(textFile, sendToServer: false);
    final codingVersion = TextCodingVersion.withId(name: 'v1', file: textFile);
    service.addCodingVersion(codingVersion, sendToServer: false);

    expect(service.project.value, isNot(equals(null)));
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.length,
      equals(1),
    );
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .name.value,
      equals('v1'),
    );
    service.updateCodingVersion(codingVersion.id,
        name: 'new name', sendToServer: false);
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .name.value,
      equals('new name'),
    );
  });

  test('ProjectService.addCoding', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');
    service.addTextFile(textFile, sendToServer: false);
    final codingVersion = TextCodingVersion.withId(name: 'v1', file: textFile);
    service.addCodingVersion(codingVersion, sendToServer: false);
    final code = Code.withId(name: 'code', color: Colors.black);
    service.addCode(code, sendToServer: false);
    service.addNewCoding(
        codingVersion, codingVersion.codingLines.value.first, code, 0, 3,
        sendToServer: false);

    expect(service.project.value, isNot(equals(null)));
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codings.value.length,
      equals(1),
    );
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codings.value.first.code,
      equals(code),
    );
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codings.value.first.start,
      equals(0),
    );
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codings.value.first.length,
      equals(3),
    );
  });

  test('ProjectService.removeCoding', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');
    service.addTextFile(textFile, sendToServer: false);
    final codingVersion = TextCodingVersion.withId(name: 'v1', file: textFile);
    service.addCodingVersion(codingVersion, sendToServer: false);
    final code = Code.withId(name: 'code', color: Colors.black);
    service.addCode(code, sendToServer: false);
    service.addNewCoding(
        codingVersion, codingVersion.codingLines.value.first, code, 0, 3);

    expect(service.project.value, isNot(equals(null)));
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codings.value.length,
      equals(1),
    );
    service.removeCoding(
      codingVersion,
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codings.value.first,
      sendToServer: false,
    );
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codings.value.length,
      equals(0),
    );
  });

  test('ProjectService.addNoteToCodingLineByIds', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');
    service.addTextFile(textFile, sendToServer: false);
    final codingVersion = TextCodingVersion.withId(name: 'v1', file: textFile);
    service.addCodingVersion(codingVersion, sendToServer: false);
    final note = Note.withId(title: 'test note', text: 'xyz');
    service.addNote(note, sendToServer: false);
    service.addNoteToCodingLineByIds(codingVersion.id, 0, note.id,
        sendToServer: false);

    expect(service.project.value, isNot(equals(null)));
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codingLines.value.first.notes.value.length,
      equals(1),
    );
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codingLines.value.first.notes.value.first.id,
      equals(note.id),
    );
  });

  test('ProjectService.removeNoteFromCodingLineByIds', () {
    final service = ProjectService();
    final textFile = TextFile.withId(name: 'test file', rawText: 'abc');
    service.addTextFile(textFile, sendToServer: false);
    final codingVersion = TextCodingVersion.withId(name: 'v1', file: textFile);
    service.addCodingVersion(codingVersion, sendToServer: false);
    final note = Note.withId(title: 'test note', text: 'xyz');
    service.addNote(note, sendToServer: false);
    service.addNoteToCodingLineByIds(codingVersion.id, 0, note.id,
        sendToServer: false);

    expect(service.project.value, isNot(equals(null)));
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codingLines.value.first.notes.value.length,
      equals(1),
    );
    service.removeNoteFromCodingLineByIds(codingVersion.id, 0, note.id,
        sendToServer: false);
    expect(
      service.project.value!.textFiles.value.first.codingVersions.value.first
          .codingLines.value.first.notes.value.length,
      equals(0),
    );
  });

  test('ProjectService.searchText', () {
    final service = ProjectService();
    final textFile =
        TextFile.withId(name: 'test file', rawText: 'asdfasf\nsfdgxyzdef');
    service.addTextFile(textFile, sendToServer: false);

    service.searchText('xyz', ignoreCase: true).listen(expectAsync1((result) {
          expect(result.file, equals(textFile));
          expect(result.line.index, equals(1));
          expect(result.offset, equals(4));
        }, count: 1, max: 1));
  });
}
