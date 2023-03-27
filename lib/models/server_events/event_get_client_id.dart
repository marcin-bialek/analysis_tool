import 'package:qdamono/models/server_events/server_event.dart';

class EventGetClientId extends ServerEvent {
  static const name = 'get_client_id';

  EventGetClientId();

  @override
  Map<String, dynamic> toJson() {
    return {
      EventGetClientIdJsonKeys.name: name,
    };
  }
}

class EventGetClientIdJsonKeys {
  static const name = 'name';
}
