import 'package:qdamono/models/code.dart';
import 'package:qdamono/models/text_coding.dart';
import 'package:flutter/material.dart';

List<InlineSpan> makeTextCodingSpans(
  String text,
  int offset,
  Iterable<TextCoding> codings,
  Iterable<EnabledCoding> enabledCodings,
) {
  if (codings.isEmpty) {
    return [TextSpan(text: text)];
  }
  final List<_CodingMark> marks = [];
  for (final c in codings) {
    for (final coding in enabledCodings) {
      if (coding.shouldEnable(c)) {
        marks.add(_CodingMark(_CodingMarkType.start, c.start - offset, c.code));
        marks.add(_CodingMark(_CodingMarkType.end, c.end - offset, c.code));
        break;
      }
    }
  }
  marks.sort((a, b) => a.offset.compareTo(b.offset));
  marks.add(_CodingMark(
    _CodingMarkType.end,
    text.length,
    Code.withId(name: '', color: Colors.white),
  ));
  List<InlineSpan> spans = [];
  Set<Code> currentCodes = {};
  for (int i = 0, j = 0, a = 0; i <= text.length && j < marks.length; i++) {
    if (i == marks[j].offset) {
      if (currentCodes.isNotEmpty) {
        final v = currentCodes.fold<int>(0, (p, c) => p + c.color.value.value) /
            currentCodes.length;
        spans.add(
          TextSpan(
            text: text.substring(a, i),
            style: TextStyle(
              backgroundColor: Color(v.toInt()).withOpacity(0.8),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: text.substring(a, i),
          ),
        );
      }
      while (j < marks.length && i == marks[j].offset) {
        if (marks[j].type == _CodingMarkType.start) {
          currentCodes.add(marks[j].code);
        } else {
          currentCodes.remove(marks[j].code);
        }
        j += 1;
      }
      a = i;
    }
  }
  return spans;
}

class EnabledCoding {
  TextCoding? coding;
  bool entireCode;

  EnabledCoding([this.coding, this.entireCode = false]);

  bool shouldEnable(TextCoding coding) {
    return this.coding == null ||
        (entireCode ? this.coding!.code == coding.code : this.coding == coding);
  }

  @override
  bool operator ==(covariant EnabledCoding other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => Object.hashAll([coding, entireCode]);
}

class _CodingMark {
  final _CodingMarkType type;
  final int offset;
  final Code code;

  _CodingMark(this.type, this.offset, this.code);

  @override
  String toString() {
    if (type == _CodingMarkType.start) {
      return '_CodingMark: start, $offset';
    }
    return '_CodingMark: end, $offset';
  }
}

enum _CodingMarkType {
  start,
  end;
}
