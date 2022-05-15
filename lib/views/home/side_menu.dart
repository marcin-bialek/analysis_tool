import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SideMenuState();
  }
}

class _SideMenuState extends State<SideMenu> {
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
            sideMenuNavigatorKey.currentState!
                .pushReplacementNamed(SideMenuRoutes.files);
          }),
          _SideMenuButton(Icons.search, 'Wyszukaj', () {
            sideMenuNavigatorKey.currentState!
                .pushReplacementNamed(SideMenuRoutes.search);
          }),
          _SideMenuButton(Icons.account_tree, 'Kodowanie', () {
            sideMenuNavigatorKey.currentState!
                .pushReplacementNamed(SideMenuRoutes.codes);
          }),
          _SideMenuButton(Icons.sticky_note_2_outlined, 'Notatki', () {
            sideMenuNavigatorKey.currentState!
                .pushReplacementNamed(SideMenuRoutes.notes);
          }),
          _SideMenuButton(Icons.people_rounded, 'Współpraca', () {
            sideMenuNavigatorKey.currentState!
                .pushReplacementNamed(SideMenuRoutes.collaboration);
          }),
          const Spacer(),
          _SideMenuButton(Icons.settings_outlined, 'Ustawienia', () {
            mainViewNavigatorKey.currentState!
                .pushReplacementNamed(MainViewRoutes.settings);
          }),
        ],
      ),
    );
  }
}

class _SideMenuButton extends StatelessWidget {
  final IconData data;
  final String tooltip;
  final void Function()? onPressed;

  const _SideMenuButton(this.data, this.tooltip, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        data,
        color: Colors.white70,
        size: 25.0,
      ),
      tooltip: tooltip,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
