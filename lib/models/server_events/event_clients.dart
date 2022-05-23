import 'package:analysis_tool/models/server_events/server_event.dart';

class EventClients extends ServerEvent {
  static const name = 'clients';
  final Map<String, String> clients = {};

  EventClients();

  factory EventClients.fromJson(Map<String, dynamic> json) {
    final clients = json[EventClientsJsonKeys.clients] as Map<String, dynamic>;
    final event = EventClients();
    event.clients.addAll(clients.cast());
    return event;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventClientsJsonKeys.name: name,
      EventClientsJsonKeys.clients: clients,
    };
  }
}

class EventClientsJsonKeys {
  static const name = 'name';
  static const clients = 'clients';
}
