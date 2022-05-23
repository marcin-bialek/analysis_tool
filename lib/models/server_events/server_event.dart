import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/server_events/event_clients.dart';

abstract class ServerEvent implements JsonEncodable {
  static ServerEvent? parse(dynamic event) {
    if (!(event is Map<String, dynamic> &&
        event.containsKey(ServerEventJsonKeys.name) &&
        event[ServerEventJsonKeys.name] is String)) {
      return null;
    }
    final name = event[ServerEventJsonKeys.name] as String;
    try {
      switch (name) {
        case EventClients.name:
          return EventClients.fromJson(event);
        default:
          return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}

class ServerEventJsonKeys {
  static const name = 'name';
}
