import 'package:analysis_tool/services/project/project_service.dart';
import 'package:analysis_tool/services/project/project_service_exceptions.dart';
import 'package:analysis_tool/views/dialogs.dart' show showDialogSaveProject;
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StartPageState();
  }
}

class _StartPageState extends State<StartPage> {
  final _projectService = ProjectService();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Strona startowa',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
          const SizedBox(height: 20.0),
          TextButton.icon(
            onPressed: () async {
              try {
                await _projectService.openProject();
              } on ProjectAlreadyOpenError {
                final result = await showDialogSaveProject(context: context);
                if (result != null) {
                  if (result == true) {
                    await _projectService.saveProject();
                  }
                  _projectService.closeProject();
                  await _projectService.openProject();
                }
              }
            },
            icon: const Icon(
              Icons.file_open,
              color: Colors.white,
            ),
            label: const Text(
              'Otwórz projekt',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
