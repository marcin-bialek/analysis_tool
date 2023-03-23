import 'package:qdamono/models/project.dart';
import 'package:qdamono/models/server_events/server_event.dart';

class EventProjectList extends ServerEvent {
  static const name = 'project_list';
  final List<Project> projects;

  EventProjectList({
    required this.projects,
  });

  factory EventProjectList.fromJson(Map<String, dynamic> json) {
    final rawProjects =
        json[EventProjectListJsonKeys.projects] as List<Map<String, dynamic>>;
    return EventProjectList(
        projects: rawProjects
            .map((rawProject) => Project.fromJson(rawProject))
            .toList());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      EventProjectListJsonKeys.name: name,
      EventProjectListJsonKeys.projects: projects,
    };
  }
}

class EventProjectListJsonKeys {
  static const name = 'name';
  static const projects = 'projects';
}
