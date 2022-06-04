import 'package:qdamono/models/project.dart';
import 'package:qdamono/models/server_events/server_event.dart';

class EventPublishProject extends ServerEvent {
  static const name = 'publishProject';
  final Project project;

  EventPublishProject({
    required this.project,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      EventPublishProjectJsonKeys.name: name,
      EventPublishProjectJsonKeys.project: project.toJson(),
    };
  }
}

class EventPublishProjectJsonKeys {
  static const name = 'name';
  static const project = 'project';
}
