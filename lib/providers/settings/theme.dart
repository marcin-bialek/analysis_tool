import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:system_theme/system_theme.dart';

part 'theme.g.dart';

@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    if (state == ThemeMode.system) {
      state = SystemTheme.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    } else {
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
  }

  void system() {
    state = ThemeMode.system;
  }
}

@riverpod
class AppFlexScheme extends _$AppFlexScheme {
  @override
  FlexScheme build() => FlexScheme.indigo;
}
