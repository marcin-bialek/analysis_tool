import 'package:qdamono/constants/keys.dart';
import 'package:qdamono/constants/routes.dart';
import 'package:qdamono/services/server/server_service.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  final void Function(bool)? showSideMenu;

  const SideMenu({
    Key? key,
    this.showSideMenu,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SideMenuState();
  }
}

class _SideMenuState extends State<SideMenu> {
  bool showSideMenu = true;
  String currentMenu = SideMenuRoutes.files;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      color: Theme.of(context).primaryColorLight,
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
      mainViewNavigatorKey.currentState?.pushReplacementNamed(name);
    } else if (name != currentMenu) {
      showSideMenu = true;
      widget.showSideMenu?.call(true);
      currentMenu = name;
      sideMenuNavigatorKey.currentState?.pushReplacementNamed(name);
    } else {
      showSideMenu = !showSideMenu;
      widget.showSideMenu?.call(showSideMenu);
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
      splashColor: Theme.of(context).primaryColor,
      highlightColor: Theme.of(context).primaryColor,
    );
  }
}
