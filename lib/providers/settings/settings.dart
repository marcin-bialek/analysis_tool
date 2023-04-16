import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

class SettingsState {
  FontSizes fontSizes = FontSizes();
  String serverAddress = "";
  bool isConnectionSecure = false;
  bool allowInsecureConnection = false;
}

@riverpod
class Settings extends _$Settings {
  SharedPreferences? _preferences;

  @override
  SettingsState build() {
    final stateValue = SettingsState();
    SharedPreferences.getInstance().then((value) {
      _preferences = value;
      _readSettings(value, stateValue);
      return value;
    });
    return stateValue;
  }

  static void _readSettings(
      SharedPreferences preferences, SettingsState state) {
    state.fontSizes = FontSizes()
      ..menuFontSize = preferences.getInt(PreferencesKeys.menuFontSize) ?? 13
      ..editorFontSize =
          preferences.getInt(PreferencesKeys.editorFontSize) ?? 15;
    state.serverAddress =
        preferences.getString(PreferencesKeys.serverAddress) ??
            'https://localhost';
    state.allowInsecureConnection =
        preferences.getBool(PreferencesKeys.allowInsecureConnection) ?? false;
  }

  void setFontSizes(FontSizes fontSizes) {
    state.fontSizes = fontSizes;
    _preferences?.setInt(PreferencesKeys.menuFontSize, fontSizes.menuFontSize);
    _preferences?.setInt(
        PreferencesKeys.editorFontSize, fontSizes.editorFontSize);
  }

  void setServerAddress(String serverAddress) {
    state.serverAddress = serverAddress;
    final uri = Uri.parse(serverAddress);
    state.isConnectionSecure = uri.scheme == 'https' || uri.scheme == 'wss';
    _preferences?.setString(PreferencesKeys.serverAddress, serverAddress);
  }

  void setAllowInsecureConnection(bool allowInsecureConnection) {
    state.allowInsecureConnection = allowInsecureConnection;
    _preferences?.setBool(
        PreferencesKeys.allowInsecureConnection, allowInsecureConnection);
  }
}

class FontSizes {
  int menuFontSize;
  int editorFontSize;

  FontSizes({this.menuFontSize = 13, this.editorFontSize = 15});
}

class PreferencesKeys {
  static const menuFontSize = 'menuFontSize';
  static const editorFontSize = 'editorFontSize';
  static const serverAddress = 'serverAddress';
  static const allowInsecureConnection = 'allowInsecureConnection';
}
