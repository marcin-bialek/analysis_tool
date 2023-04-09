import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/json_encodable.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/models/observable.dart';
import 'package:qdamono/models/text_coding.dart';
import 'package:qdamono/models/text_file.dart';
import 'package:uuid/uuid.dart';

class TextCodingVersion implements JsonEncodable {
  final String id;
  final TextFile file;
  final Observable<String> name;
  final codings = Observable<Set<TextCoding>>({});
  final notes = Observable<Map<int, Set<Note>>>({});
  Observable<List<TextCodingLine>>? _codingLines;
  Observable<List<TextCodingLine>> get codingLines {
    if (_codingLines == null) {
      _codingLines = Observable<List<TextCodingLine>>([]);
      _makeCodingLines();
    }
    return _codingLines!;
  }

  TextCodingVersion({
    required this.id,
    required this.file,
    required String name,
  }) : name = Observable(name);

  factory TextCodingVersion.withId({
    required String name,
    required TextFile file,
  }) {
    final id = const Uuid().v4();
    return TextCodingVersion(id: id, name: name, file: file);
  }

  factory TextCodingVersion.fromJson(
    Map<String, dynamic> json,
    TextFile file,
    Iterable<Code> codes,
    Iterable<Note> notes,
  ) {
    final id = json[TextCodingVersionJsonKeys.id];
    final name = json[TextCodingVersionJsonKeys.name];
    final version = TextCodingVersion(id: id, name: name, file: file);
    final codings = json[TextCodingVersionJsonKeys.codings] as List;
    version.codings.value
        .addAll(codings.map((e) => TextCoding.fromJson(e, codes)));
    for (final note in notes) {
      final indices = note.codingLines[id];
      if (indices != null) {
        for (final index in indices) {
          version.notes.value.putIfAbsent(index, () => <Note>{});
          version.notes.value[index]!.add(note);
        }
      }
    }
    return version;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TextCodingVersionJsonKeys.id: id,
      TextCodingVersionJsonKeys.name: name.value,
      TextCodingVersionJsonKeys.codings:
          codings.value.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(covariant TextCodingVersion other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  Future<void> _makeCodingLines() async {
    _codingLines?.value.clear();
    for (final line in file.textLines.value) {
      final codingLine = TextCodingLine(textLine: line);
      for (final coding in codings.value) {
        if (line.offset <= coding.start && coding.start < line.endOffset) {
          codingLine.codings.value.add(coding);
        } else if (line.offset < coding.end && coding.end < line.endOffset) {
          codingLine.codings.value.add(coding);
        }
      }
      final lineNotes = notes.value[line.index];
      if (lineNotes != null) {
        codingLine.notes.value.addAll(lineNotes);
      }
      _codingLines?.value.add(codingLine);
    }
  }

  void removeCode(Code code) {
    if (_codingLines != null) {
      for (final line in _codingLines!.value) {
        line.codings.value.removeWhere((c) => c.code == code);
        line.codings.notify();
      }
    }
    codings.value.removeWhere((c) => c.code == code);
    codings.notify();
  }

  void updatedCode(Code code) {
    for (var line in _codingLines?.value ?? []) {
      if (line.codings.value.map((c) => c.code).contains(code)) {
        line.codings.notify();
      }
    }
  }

  void removeNote(Note note) {
    if (_codingLines != null) {
      for (final line in _codingLines!.value) {
        if (line.notes.value.remove(note)) {
          line.notes.notify();
        }
      }
    }
    for (var notes in notes.value.values) {
      notes.remove(note);
    }
    notes.notify();
  }

  void addNoteToLine(int lineIndex, Note note) {
    notes.value.putIfAbsent(lineIndex, () => <Note>{});
    notes.value[lineIndex]!.add(note);
    notes.notify();
    _codingLines?.value[lineIndex].notes.value.add(note);
    _codingLines?.value[lineIndex].notes.notify();
  }

  void removeNoteFromLine(int lineIndex, Note note) {
    notes.value[lineIndex]?.remove(note);
    notes.notify();
    _codingLines?.value[lineIndex].notes.value.remove(note);
    _codingLines?.value[lineIndex].notes.notify();
  }
}

class TextCodingVersionJsonKeys {
  static const id = '_id';
  static const name = 'name';
  static const codings = 'codings';
}

class TextCodingLine {
  final TextLine textLine;
  final codings = Observable<Set<TextCoding>>({});
  final notes = Observable<Set<Note>>({});

  TextCodingLine({required this.textLine});
}
