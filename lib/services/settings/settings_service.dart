import 'package:qdamono/models/observable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static SettingsService? _instance;
  SharedPreferences? _preferences;
  final fontSizes = Observable(FontSizes());
  final serverAddress = Observable('https://localhost');
  final isConnectionSecure = Observable(false);
  final allowInsecureConnection = Observable(false);

  SettingsService._() {
    fontSizes.addListener((sizes) async {
      _preferences?.setInt(PreferencesKeys.menuFontSize, sizes.menuFontSize);
      _preferences?.setInt(
          PreferencesKeys.editorFontSize, sizes.editorFontSize);
    });
    serverAddress.addListener((address) {
      _preferences?.setString(PreferencesKeys.serverAddress, address);
      final uri = Uri.parse(address);
      isConnectionSecure.value = uri.scheme == 'https' || uri.scheme == 'wss';
    });
    allowInsecureConnection.addListener((doAllow) {
      _preferences?.setBool(PreferencesKeys.allowInsecureConnection, doAllow);
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
    serverAddress.value =
        _preferences!.getString(PreferencesKeys.serverAddress) ??
            'https://localhost';
    allowInsecureConnection.value =
        _preferences!.getBool(PreferencesKeys.allowInsecureConnection) ?? false;
  }
}

class FontSizes {
  int menuFontSize = 13;
  int editorFontSize = 15;
}

class PreferencesKeys {
  static const menuFontSize = 'menuFontSize';
  static const editorFontSize = 'editorFontSize';
  static const serverAddress = 'serverAddress';
  static const allowInsecureConnection = 'allowInsecureConnection';
}
