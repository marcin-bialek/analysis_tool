import 'package:analysis_tool/models/server_events/server_event.dart';
import 'package:flutter/material.dart';

class EventCodeUpdate extends ServerEvent {
  static const name = 'codeUpdate';
  final String codeId;
  final String? codeName;
  final Color? codeColor;

  EventCodeUpdate({
    required this.codeId,
    this.codeName,
    this.codeColor,
  });

  factory EventCodeUpdate.fromJson(Map<String, dynamic> json) {
    final codeId = json[EventCodeUpdateJsonKeys.codeId];
    final codeName = json[EventCodeUpdateJsonKeys.codeName];
    final codeColor = json[EventCodeUpdateJsonKeys.codeColor];
    return EventCodeUpdate(
      codeId: codeId,
      codeName: codeName,
      codeColor: codeColor != null ? Color(codeColor) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodeUpdateJsonKeys.name: name,
      EventCodeUpdateJsonKeys.codeId: codeId,
      if (codeName != null) EventCodeUpdateJsonKeys.codeName: codeName,
      if (codeColor != null)
        EventCodeUpdateJsonKeys.codeColor: codeColor!.value,
    };
  }
}

class EventCodeUpdateJsonKeys {
  static const name = 'name';
  static const codeId = 'codeId';
  static const codeName = 'codeName';
  static const codeColor = 'codeColor';
}
