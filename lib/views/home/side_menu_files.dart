import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:flutter/material.dart';

class SideMenuFiles extends StatefulWidget {
  const SideMenuFiles({Key? key}) : super(key: key);

  @override
  State<SideMenuFiles> createState() => _SideMenuFilesState();
}

class _SideMenuFilesState extends State<SideMenuFiles> {
  final _projectService = ProjectService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 20.0),
            const Text(
              'Pliki',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: _projectService.addFile,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _projectService.saveProject,
              icon: const Icon(
                Icons.save,
                size: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<TextFile>>(
            stream: _projectService.filesStream,
            initialData: const [],
            builder: (context, snap) {
              switch (snap.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return ListView.builder(
                    itemCount: snap.data!.length,
                    itemBuilder: (context, index) {
                      final file = snap.data![index];
                      return SideMenuFilesItem(file: file);
                    },
                  );
                default:
                  return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}

class SideMenuFilesItem extends StatelessWidget {
  final TextFile file;

  const SideMenuFilesItem({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.file_copy,
            color: Colors.white,
            size: 14.0,
          ),
          title: Text(
            file.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.0,
            ),
          ),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0.0,
            horizontal: 20.0,
          ),
          horizontalTitleGap: 10.0,
          minLeadingWidth: 0.0,
          minVerticalPadding: 0.0,
          visualDensity: const VisualDensity(vertical: -4.0),
          onTap: () {},
          onLongPress: () {},
        ),
        // for (final v in file.codingVersions)
        //   ListTile(
        //     leading: Icon(Icons.arrow_right, color: Colors.white, size: 14.0),
        //     title: Text(v.name,
        //         style: TextStyle(color: Colors.white, fontSize: 13.0)),
        //     dense: true,
        //     contentPadding: EdgeInsets.only(left: 40.0),
        //     horizontalTitleGap: 10.0,
        //     minLeadingWidth: 0.0,
        //     minVerticalPadding: 0.0,
        //     visualDensity: VisualDensity(vertical: -4.0),
        //     onTap: () {
        //       AppState.mainMenuNavigatorKey.currentState
        //           ?.pushReplacementNamed('/editor', arguments: v);
        //     },
        //   ),
      ],
    );
  }
}
