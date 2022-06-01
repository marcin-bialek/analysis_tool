import 'package:analysis_tool/models/observable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static SettingsService? _instance;
  SharedPreferences? _preferences;
  final fontSizes = Observable(FontSizes());
  final username = Observable('bez nazwy');

  SettingsService._() {
    fontSizes.addListener((sizes) async {
      _preferences?.setInt(PreferencesKeys.menuFontSize, sizes.menuFontSize);
      _preferences?.setInt(
          PreferencesKeys.editorFontSize, sizes.editorFontSize);
    });
    username.addListener((username) {
      _preferences?.setString(PreferencesKeys.username, username);
    });
    _readSettings();
  }

  factory SettingsService() {
    _instance ??= SettingsService._();
    return _instance!;
  }

  Future<void> _readSettings() async {
    _preferences ??= await SharedPreferences.getInstance();
    fontSizes.value = FontSizes()
      ..menuFontSize = _preferences!.getInt(PreferencesKeys.menuFontSize) ?? 13
      ..editorFontSize =
          _preferences!.getInt(PreferencesKeys.editorFontSize) ?? 15;
    username.value =
        _preferences!.getString(PreferencesKeys.username) ?? 'bez nazwy';
  }
}

class FontSizes {
  int menuFontSize = 13;
  int editorFontSize = 15;
}

class PreferencesKeys {
  static const menuFontSize = 'menuFontSize';
  static const editorFontSize = 'editorFontSize';
  static const username = 'username';
}
