import 'package:qdamono/models/server_events/server_event.dart';

class EventGetProject extends ServerEvent {
  static const name = 'getProject';
  final String passcode;

  EventGetProject({
    required this.passcode,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      EventGetProjectJsonKeys.name: name,
      EventGetProjectJsonKeys.passcode: passcode,
    };
  }
}

class EventGetProjectJsonKeys {
  static const name = 'name';
  static const passcode = 'passcode';
}
