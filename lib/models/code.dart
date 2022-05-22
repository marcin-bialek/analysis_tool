import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/observable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Code implements JsonEncodable {
  final String id;
  final Observable<String> name;
  final Observable<Color> color;

  Code({
    required this.id,
    required String name,
    required Color color,
  })  : name = Observable(name),
        color = Observable(color);

  factory Code.withId({
    required String name,
    required Color color,
  }) {
    final id = const Uuid().v4();
    return Code(id: id, name: name, color: color);
  }

  factory Code.fromJson(Map<String, dynamic> json) {
    final id = json[CodeJsonKeys.id];
    final name = json[CodeJsonKeys.name];
    final color = Color(json[CodeJsonKeys.color]);
    return Code(id: id, name: name, color: color);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      CodeJsonKeys.id: id,
      CodeJsonKeys.name: name.value,
      CodeJsonKeys.color: color.value.value,
    };
  }

  @override
  bool operator ==(covariant Code other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CodeJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const color = 'color';
}
