import 'package:qdamono/models/server_events/server_event.dart';

class EventGetProjectList extends ServerEvent {
  static const name = 'get_project_list';

  EventGetProjectList();

  @override
  Map<String, dynamic> toJson() {
    return {
      EventGetProjectListJsonKeys.name: name,
    };
  }
}

class EventGetProjectListJsonKeys {
  static const name = 'name';
}
