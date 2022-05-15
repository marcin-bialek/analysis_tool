import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/views/home/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analysis Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      body: Row(
        children: [
          const SideMenu(),
          Expanded(
            child: MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerThickness: 2,
                dividerPainter: DividerPainters.background(
                  color: const Color.fromARGB(255, 51, 51, 51),
                ),
              ),
              child: MultiSplitView(
                initialAreas: [Area(weight: 0.2), Area(weight: 0.8)],
                children: [
                  Navigator(
                    key: sideMenuNavigatorKey,
                    initialRoute: SideMenuRoutes.files,
                    onGenerateRoute: _sideMenuOnGenerateRoute,
                  ),
                  Navigator(
                    key: mainViewNavigatorKey,
                    initialRoute: MainViewRoutes.start,
                    onGenerateRoute: _mainViewOnGenerateRoute,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Route _sideMenuOnGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) {
        switch (settings.name) {
          case SideMenuRoutes.files:
            return const Text('files');
          case SideMenuRoutes.search:
            return const Text('search');
          case SideMenuRoutes.codes:
            return const Text('codes');
          case SideMenuRoutes.notes:
            return const Text('notes');
          case SideMenuRoutes.collaboration:
            return const Text('collaboration');
          default:
            return Container();
        }
      },
      settings: settings,
      transitionDuration: Duration.zero,
    );
  }

  Route _mainViewOnGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) {
        switch (settings.name) {
          case MainViewRoutes.start:
            return const Text('start');
          case MainViewRoutes.settings:
            return const Text('settings');
          case MainViewRoutes.editor:
            return const Text('editor');
          case MainViewRoutes.codeGraph:
            return const Text('code graph');
          case MainViewRoutes.compare:
            return const Text('compare');
          default:
            return Container();
        }
      },
      settings: settings,
      transitionDuration: Duration.zero,
    );
  }
}
