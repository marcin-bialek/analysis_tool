import 'package:qdamono/models/json_encodable.dart';
import 'package:qdamono/models/observable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Code implements JsonEncodable {
  final String id;
  final Observable<String> name;
  final Observable<Color> color;
  final children = Observable<Set<Code>>({});
  final String? parentId;

  Code({
    required this.id,
    required String name,
    required Color color,
    this.parentId,
  })  : name = Observable(name),
        color = Observable(color);

  factory Code.withId({
    required String name,
    required Color color,
    String? parentId,
  }) {
    final id = const Uuid().v4();
    return Code(id: id, name: name, color: color, parentId: parentId);
  }

  factory Code.fromJson(Map<String, dynamic> json) {
    final id = json[CodeJsonKeys.id];
    final name = json[CodeJsonKeys.name];
    final color = Color(json[CodeJsonKeys.color]);
    final parentId = json[CodeJsonKeys.parentId];
    return Code(id: id, name: name, color: color, parentId: parentId);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      CodeJsonKeys.id: id,
      CodeJsonKeys.name: name.value,
      CodeJsonKeys.color: color.value.value,
      CodeJsonKeys.parentId: parentId,
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
  static const parentId = 'parentId';
}
