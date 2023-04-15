import 'package:flutter/material.dart';
import 'package:qdamono/constants/defaults.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'side_menu.g.dart';

@riverpod
class SideMenuWidth extends _$SideMenuWidth {
  @override
  double build() =>
      (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width -
          AppDefaults.sideMenuBarWidth) *
      0.2;

  void set(double newWidth) {
    state = newWidth;
  }
}
