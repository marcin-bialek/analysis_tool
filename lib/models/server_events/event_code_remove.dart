import 'package:qdamono/models/server_events/server_event.dart';

class EventCodeRemove extends ServerEvent {
  static const name = 'code_remove';
  final String codeId;

  EventCodeRemove({
    required this.codeId,
  });

  factory EventCodeRemove.fromJson(Map<String, dynamic> json) {
    final codeId = json[EventCodeRemoveJsonKeys.codeId] as String;
    return EventCodeRemove(codeId: codeId);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodeRemoveJsonKeys.name: name,
      EventCodeRemoveJsonKeys.codeId: codeId,
    };
  }
}

class EventCodeRemoveJsonKeys {
  static const name = 'name';
  static const codeId = 'code_id';
}
