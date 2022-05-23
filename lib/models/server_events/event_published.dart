import 'package:analysis_tool/models/server_events/server_event.dart';

class EventPublished extends ServerEvent {
  static const name = 'published';
  final String passcode;

  EventPublished({
    required this.passcode,
  });

  factory EventPublished.fromJson(Map<String, dynamic> json) {
    final passcode = json['passcode'] as String;
    return EventPublished(passcode: passcode);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventPublishedJsonKeys.name: name,
      EventPublishedJsonKeys.passcode: passcode,
    };
  }
}

class EventPublishedJsonKeys {
  static const name = 'name';
  static const passcode = 'passcode';
}
