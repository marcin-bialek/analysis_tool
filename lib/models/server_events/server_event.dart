import 'package:analysis_tool/models/json_encodable.dart';
import 'package:analysis_tool/models/server_events/event_clients.dart';
import 'package:analysis_tool/models/server_events/event_code_add.dart';
import 'package:analysis_tool/models/server_events/event_code_remove.dart';
import 'package:analysis_tool/models/server_events/event_project.dart';
import 'package:analysis_tool/models/server_events/event_published.dart';

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
        case EventProject.name:
          return EventProject.fromJson(event);
        case EventPublished.name:
          return EventPublished.fromJson(event);
        case EventCodeAdd.name:
          return EventCodeAdd.fromJson(event);
        case EventCodeRemove.name:
          return EventCodeRemove.fromJson(event);
        default:
          print('Unknown event: $name');
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
