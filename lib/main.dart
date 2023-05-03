import 'package:qdamono/constants/keys.dart';
import 'package:qdamono/constants/routes.dart';
import 'package:qdamono/models/note.dart';
import 'package:qdamono/models/text_coding_version.dart';
import 'package:qdamono/services/settings/settings_service.dart';
import 'package:qdamono/views/code_stats/code_stats_view.dart';
import 'package:qdamono/views/coding_compare/coding_compare_view.dart';
import 'package:qdamono/views/coding_editor/coding_editor.dart';
import 'package:qdamono/views/flow_charts/flow_chart_editor.dart';
import 'package:qdamono/views/project_list/project_list_view.dart';
import 'package:qdamono/views/side_menu/side_menu.dart';
import 'package:qdamono/views/side_menu/side_menu_codes.dart';
import 'package:qdamono/views/side_menu/side_menu_collaboration.dart';
import 'package:qdamono/views/side_menu/side_menu_files.dart';
import 'package:qdamono/views/side_menu/side_menu_notes.dart';
import 'package:qdamono/views/side_menu/side_menu_search.dart';
import 'package:qdamono/views/note_view/note_view.dart';
import 'package:qdamono/views/settings/settings_view.dart';
import 'package:qdamono/views/start/start_page.dart';
import 'package:qdamono/views/text_editor/text_editor.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsService().fontSizes.observe((sizes) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QDAmono',
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 30, 30, 30),
          primaryColorLight: const Color.fromARGB(255, 51, 51, 51),
          primaryTextTheme: TextTheme(
            bodyText2: TextStyle(
              color: Colors.white,
              fontSize: sizes.menuFontSize.toDouble(),
            ),
            button: TextStyle(
              color: Colors.blue,
              fontSize: sizes.menuFontSize.toDouble(),
            ),
          ),
          primaryIconTheme: const IconThemeData(color: Colors.white),
          canvasColor: const Color.fromARGB(255, 238, 238, 238),
          textTheme: TextTheme(
            bodyText2: TextStyle(
              color: Colors.black,
              fontSize: sizes.editorFontSize.toDouble(),
            ),
          ),
          hintColor: Colors.white,
          errorColor: Colors.red,
        ),
        home: const HomePage(),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MultiSplitViewController? splitViewController;

  @override
  void initState() {
    super.initState();
    splitViewController = MultiSplitViewController(areas: Area.weights([0.2]));
  }

  @override
  void dispose() {
    splitViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Row(
        children: [
          SideMenu(showSideMenu: (value) {
            splitViewController?.areas = Area.weights([value ? 0.2 : 0.0]);
          }),
          Expanded(
            child: MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerThickness: 2,
                dividerPainter: DividerPainters.background(
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
              child: MultiSplitView(
                controller: splitViewController,
                children: const [
                  SideView(
                    initialRoute: SideMenuRoute.files,
                  ),
                  MainView(
                    initialRoute: MainViewRoute.none,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SideView extends StatelessWidget {
  final SideMenuRoute initialRoute;

  const SideView({required this.initialRoute, Key? key}) : super(key: key);

  Route _onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) {
        return {
              SideMenuRoutePaths.files: const SideMenuFiles(),
              SideMenuRoutePaths.search: const SideMenuSearch(),
              SideMenuRoutePaths.codes: const SideMenuCodes(),
              SideMenuRoutePaths.notes: const SideMenuNotes(),
              SideMenuRoutePaths.collaboration: const SideMenuCollaboration(),
            }[settings.name] ??
            Container();
      },
      settings: settings,
      transitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: sideMenuNavigatorKey,
      initialRoute: initialRoute.path,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

class MainView extends StatelessWidget {
  final MainViewRoute initialRoute;

  const MainView({required this.initialRoute, Key? key}) : super(key: key);

  Route _onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) {
        switch (settings.name) {
          case MainViewRoutePaths.start:
            return const StartPage();
          case MainViewRoutePaths.settings:
            return const SettingsView();
          case MainViewRoutePaths.projectList:
            return const ProjectListView();
          case MainViewRoutePaths.textEditor:
            final args = settings.arguments as List;
            return TextEditor(file: args[0], line: args[1]);
          case MainViewRoutePaths.codingEditor:
            return CodingEditor(
              codingVersion: settings.arguments as TextCodingVersion,
            );
          case MainViewRoutePaths.codingCompare:
            final args = settings.arguments as List;
            return CodingCompareView(
              firstVersion: args[0],
              secondVersion: args[1],
            );
          case MainViewRoutePaths.codeStats:
            return const CodeStatsView();
          case MainViewRoutePaths.codeGraph:
            return const Text('graf kodów',
                style: TextStyle(color: Colors.white));
          case MainViewRoutePaths.note:
            return NoteView(note: settings.arguments as Note);
          case MainViewRoutePaths.flowChart:
            return const FlowchartEditorView();
          case MainViewRoutePaths.none:
          default:
            return Container();
        }
      },
      settings: settings,
      transitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: mainViewNavigatorKey,
      initialRoute: initialRoute.path,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
