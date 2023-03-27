import 'package:qdamono/models/json_encodable.dart';
import 'package:uuid/uuid.dart';

class ProjectInfo implements JsonEncodable {
  final String id;
  final String name;

  ProjectInfo({
    required this.id,
    required this.name,
  });

  factory ProjectInfo.withId({
    required String name,
  }) {
    final id = const Uuid().v4();
    return ProjectInfo(id: id, name: name);
  }

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    final id = json[ProjectInfoJsonKeys.id];
    final name = json[ProjectInfoJsonKeys.name];
    final projectInfo = ProjectInfo(id: id, name: name);
    return projectInfo;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ProjectInfoJsonKeys.id: id,
      ProjectInfoJsonKeys.name: name,
    };
  }

  @override
  bool operator ==(covariant ProjectInfo other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ProjectInfoJsonKeys {
  static const id = 'id';
  static const name = 'name';
}
