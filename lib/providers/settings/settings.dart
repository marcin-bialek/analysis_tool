import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';
part 'settings.freezed.dart';

@freezed
class FontSizes with _$FontSizes {
  const factory FontSizes({
    @Default(13) int menuFontSize,
    @Default(15) int editorFontSize,
  }) = _FontSizes;
}

@freezed
class SettingsState with _$SettingsState {
  const SettingsState._();

  const factory SettingsState({
    @Default(FontSizes()) FontSizes fontSizes,
    @Default('https://qdamono.xyz') String serverAddress,
    @Default(false) bool allowInsecureConnection,
  }) = _SettingsState;

  bool get isConnectionSecure {
    final uri = Uri.parse(serverAddress);
    return uri.scheme == 'https' || uri.scheme == 'wss';
  }
}

@riverpod
class Settings extends _$Settings {
  static SharedPreferences? _preferences;

  @override
  FutureOr<SettingsState> build() async {
    ref.keepAlive();
    if (kDebugMode) {
      print('Settings build');
    }

    _preferences ??= await SharedPreferences.getInstance();

    return _readSettings(_preferences!);
  }

  static SettingsState _readSettings(SharedPreferences preferences) {
    final fontSizes = FontSizes(
        menuFontSize: preferences.getInt(PreferencesKeys.menuFontSize) ?? 13,
        editorFontSize:
            preferences.getInt(PreferencesKeys.editorFontSize) ?? 15);

    final serverAddress =
        preferences.getString(PreferencesKeys.serverAddress) ??
            'https://localhost';
    final allowInsecureConnection =
        preferences.getBool(PreferencesKeys.allowInsecureConnection) ?? false;

    return SettingsState(
        fontSizes: fontSizes,
        serverAddress: serverAddress,
        allowInsecureConnection: allowInsecureConnection);
  }

  void setFontSizes(FontSizes fontSizes) {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(fontSizes: fontSizes));
      _preferences?.setInt(
          PreferencesKeys.menuFontSize, fontSizes.menuFontSize);
      _preferences?.setInt(
          PreferencesKeys.editorFontSize, fontSizes.editorFontSize);
    }
  }

  void setServerAddress(String serverAddress) {
    if (state.hasValue) {
      state =
          AsyncValue.data(state.value!.copyWith(serverAddress: serverAddress));
      _preferences?.setString(PreferencesKeys.serverAddress, serverAddress);
    }
  }

  void setAllowInsecureConnection(bool allowInsecureConnection) {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!
          .copyWith(allowInsecureConnection: allowInsecureConnection));
      _preferences?.setBool(
          PreferencesKeys.allowInsecureConnection, allowInsecureConnection);
    }
  }
}

class PreferencesKeys {
  static const menuFontSize = 'menuFontSize';
  static const editorFontSize = 'editorFontSize';
  static const serverAddress = 'serverAddress';
  static const allowInsecureConnection = 'allowInsecureConnection';
}
