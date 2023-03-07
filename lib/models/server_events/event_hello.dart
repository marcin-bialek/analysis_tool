import 'package:qdamono/models/server_events/server_event.dart';

class EventHello extends ServerEvent {
  static const name = 'hello';
  final String clientId;
  final String username;

  EventHello({
    required this.clientId,
    required this.username,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      EventHelloJsonKeys.name: name,
      EventHelloJsonKeys.clientId: clientId,
      EventHelloJsonKeys.username: username,
    };
  }
}

class EventHelloJsonKeys {
  static const name = 'name';
  static const clientId = 'client_id';
  static const username = 'username';
}
