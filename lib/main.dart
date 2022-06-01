import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/models/note.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/views/code_stats/code_stats_view.dart';
import 'package:analysis_tool/views/coding_editor/coding_editor.dart';
import 'package:analysis_tool/views/home/side_menu.dart';
import 'package:analysis_tool/views/home/side_menu_codes.dart';
import 'package:analysis_tool/views/home/side_menu_collaboration.dart';
import 'package:analysis_tool/views/home/side_menu_files.dart';
import 'package:analysis_tool/views/home/side_menu_notes.dart';
import 'package:analysis_tool/views/home/side_menu_search.dart';
import 'package:analysis_tool/views/note_view/note_view.dart';
import 'package:analysis_tool/views/settings/settings_view.dart';
import 'package:analysis_tool/views/start/start_page.dart';
import 'package:analysis_tool/views/text_editor/text_editor.dart';
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
      debugShowCheckedModeBanner: false,
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
        return {
              SideMenuRoutes.files: const SideMenuFiles(),
              SideMenuRoutes.search: const SideMenuSearch(),
              SideMenuRoutes.codes: const SideMenuCodes(),
              SideMenuRoutes.notes: const SideMenuNotes(),
              SideMenuRoutes.collaboration: const SideMenuCollaboration(),
            }[settings.name] ??
            Container();
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
            return const StartPage();
          case MainViewRoutes.settings:
            return const SettingsView();
          case MainViewRoutes.textEditor:
            final args = settings.arguments as List;
            return TextEditor(file: args[0], line: args[1]);
          case MainViewRoutes.codingEditor:
            return CodingEditor(
                codingVersion: settings.arguments as TextCodingVersion);
          case MainViewRoutes.codeStats:
            return const CodeStatsView();
          case MainViewRoutes.codeGraph:
            return const Text('graf kodów',
                style: TextStyle(color: Colors.white));
          case MainViewRoutes.compare:
            return const Text('porównywanie',
                style: TextStyle(color: Colors.white));
          case MainViewRoutes.note:
            return NoteView(note: settings.arguments as Note);
          case MainViewRoutes.none:
          default:
            return Container();
        }
      },
      settings: settings,
      transitionDuration: Duration.zero,
    );
  }
}
