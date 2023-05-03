import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qdamono/constants/defaults.dart';
import 'package:qdamono/constants/keys.dart';
import 'package:qdamono/constants/routes.dart';
import 'package:qdamono/providers/settings/theme.dart';
import 'package:qdamono/services/server/server_service.dart';
import 'package:flutter/material.dart';

class SideMenu extends ConsumerStatefulWidget {
  final void Function(bool)? showSideMenu;

  const SideMenu({
    Key? key,
    this.showSideMenu,
  }) : super(key: key);

  @override
  ConsumerState<SideMenu> createState() {
    return _SideMenuState();
  }
}

class _SideMenuState extends ConsumerState<SideMenu> {
  bool showSideMenu = true;
  SideMenuRoute currentMenu = SideMenuRoute.files;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDefaults.sideMenuBarWidth,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10.0),
          _SideMenuButton(Icons.home_outlined, 'Projekt', () {
            _openProjectList();
          }),
          _SideMenuButton(Icons.content_copy_outlined, 'Pliki', () {
            _openMenu(SideMenuRoute.files);
          }),
          _SideMenuButton(Icons.search, 'Wyszukaj', () {
            _openMenu(SideMenuRoute.search);
          }),
          _SideMenuButton(Icons.account_tree, 'Kodowanie', () {
            _openMenu(SideMenuRoute.codes);
          }),
          _SideMenuButton(Icons.sticky_note_2_outlined, 'Notatki', () {
            _openMenu(SideMenuRoute.notes);
          }),
          ServerService().connectionInfo.state.observe((state) {
            return _SideMenuButton(
              Icons.people_rounded,
              'Współpraca',
              () {
                _openMenu(SideMenuRoute.collaboration);
              },
              color: state == ServerConnectionState.connected
                  ? Colors.green
                  : null,
            );
          }),
          _SideMenuButton(Icons.draw, 'Diagram', () {
            _openFlowChartEditor();
          }),
          const Spacer(),
          kDebugMode
              ? _SideMenuButton(Icons.question_mark, '<debug> Start', () {
                  mainViewNavigatorKey.currentState
                      ?.pushReplacementNamed(MainViewRoutePaths.start);
                }, color: Colors.red)
              : const SizedBox.shrink(),
          kDebugMode
              ? _SideMenuButton(Icons.mode_edit, '<debug> Theme', () {
                  ref.read(appThemeModeProvider.notifier).toggle();
                }, color: Colors.red)
              : const SizedBox.shrink(),
          _SideMenuButton(Icons.settings_outlined, 'Ustawienia', () {
            _openSettings();
          }),
        ],
      ),
    );
  }

  void _openMenu(SideMenuRoute route) {
    if (route != currentMenu) {
      showSideMenu = true;
      widget.showSideMenu?.call(true);
      currentMenu = route;
      sideMenuNavigatorKey.currentState?.pushReplacementNamed(route.path);
    } else {
      showSideMenu = !showSideMenu;
      widget.showSideMenu?.call(showSideMenu);
    }
  }

  void _openSettings() {
    mainViewNavigatorKey.currentState
        ?.pushReplacementNamed(MainViewRoutePaths.settings);
  }

  void _openProjectList() {
    mainViewNavigatorKey.currentState
        ?.pushReplacementNamed(MainViewRoutePaths.projectList);
  }

  void _openFlowChartEditor() {
    mainViewNavigatorKey.currentState
        ?.pushReplacementNamed(MainViewRoutePaths.flowChart);
  }
}

class _SideMenuButton extends StatelessWidget {
  final IconData data;
  final String tooltip;
  final Color? color;
  final void Function()? onPressed;

  const _SideMenuButton(this.data, this.tooltip, this.onPressed, {this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(seconds: 1),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          data,
          color: color ?? Theme.of(context).colorScheme.onPrimaryContainer,
          size: 25.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        splashColor: Theme.of(context).primaryColor,
        highlightColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
