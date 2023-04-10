import 'package:qdamono/constants/privilege_level.dart';
import 'package:qdamono/models/json_encodable.dart';

class ProjectInfo implements JsonEncodable {
  final String id;
  final String name;
  final PrivilegeLevel privilegeLevel;

  ProjectInfo({
    required this.id,
    required this.name,
    required this.privilegeLevel,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    final id = json[ProjectInfoJsonKeys.id];
    final name = json[ProjectInfoJsonKeys.name];
    final privilegeLevel = json[ProjectInfoJsonKeys.privilegeLevel];
    final projectInfo = ProjectInfo(
        id: id,
        name: name,
        privilegeLevel: PrivilegeLevel.values
            .firstWhere((element) => element.value == privilegeLevel));
    return projectInfo;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ProjectInfoJsonKeys.id: id,
      ProjectInfoJsonKeys.name: name,
      ProjectInfoJsonKeys.privilegeLevel: privilegeLevel.index,
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
  static const id = '_id';
  static const name = 'name';
  static const privilegeLevel = 'privilege';
}
