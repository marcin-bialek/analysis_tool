import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/services/server/server_service.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SideMenuState();
  }
}

class _SideMenuState extends State<SideMenu> {
  String _currentMenu = SideMenuRoutes.notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      color: const Color.fromARGB(255, 51, 51, 51),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10.0),
          _SideMenuButton(Icons.content_copy_outlined, 'Pliki', () {
            _openMenu(SideMenuRoutes.files);
          }),
          _SideMenuButton(Icons.search, 'Wyszukaj', () {
            _openMenu(SideMenuRoutes.search);
          }),
          _SideMenuButton(Icons.account_tree, 'Kodowanie', () {
            _openMenu(SideMenuRoutes.codes);
          }),
          _SideMenuButton(Icons.sticky_note_2_outlined, 'Notatki', () {
            _openMenu(SideMenuRoutes.notes);
          }),
          ServerService().connectionInfo.state.observe((state) {
            return _SideMenuButton(
              Icons.people_rounded,
              'Współpraca',
              () {
                _openMenu(SideMenuRoutes.collaboration);
              },
              color: state == ServerConnectionState.connected
                  ? Colors.green
                  : null,
            );
          }),
          const Spacer(),
          _SideMenuButton(Icons.settings_outlined, 'Ustawienia', () {
            _openMenu(MainViewRoutes.settings);
          }),
        ],
      ),
    );
  }

  void _openMenu(String name) {
    if (name == MainViewRoutes.settings) {
      mainViewNavigatorKey.currentState!.pushReplacementNamed(name);
    } else if (name != _currentMenu) {
      _currentMenu = name;
      sideMenuNavigatorKey.currentState!.pushReplacementNamed(name);
    }
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
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        data,
        color: color ?? Colors.white70,
        size: 25.0,
      ),
      tooltip: tooltip,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
