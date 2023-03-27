import 'package:qdamono/models/server_events/server_event.dart';

class EventClientId extends ServerEvent {
  static const name = 'client_id';
  final String clientId;

  EventClientId({
    required this.clientId,
  });

  factory EventClientId.fromJson(Map<String, dynamic> json) {
    return EventClientId(clientId: json[EventClientIdJsonKeys.clientId]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventClientIdJsonKeys.name: name,
      EventClientIdJsonKeys.clientId: clientId,
    };
  }
}

class EventClientIdJsonKeys {
  static const name = 'name';
  static const clientId = 'client_id';
}
