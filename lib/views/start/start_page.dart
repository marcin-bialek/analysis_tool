import 'package:analysis_tool/services/project/project_service.dart';
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
            onPressed: () {
              // TODO: handle ProjectAlreadyOpenError
              _projectService.openProject();
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
