import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/server_events/server_event.dart';

class EventCodeAdd extends ServerEvent {
  static const name = 'codeAdd';
  final Code code;

  EventCodeAdd({
    required this.code,
  });

  factory EventCodeAdd.fromJson(Map<String, dynamic> json) {
    final code = json[EventCodeAddJsonKeys.code] as Map<String, dynamic>;
    return EventCodeAdd(code: Code.fromJson(code));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventCodeAddJsonKeys.name: name,
      EventCodeAddJsonKeys.code: code.toJson(),
    };
  }
}

class EventCodeAddJsonKeys {
  static const name = 'name';
  static const code = 'code';
}
