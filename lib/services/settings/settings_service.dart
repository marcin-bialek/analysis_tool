import 'package:analysis_tool/models/observable.dart';

class SettingsService {
  static SettingsService? _instance;
  final fontSizes = Observable(FontSizes());
  final username = Observable('bez nazwy');

  SettingsService._();

  factory SettingsService() {
    _instance ??= SettingsService._();
    return _instance!;
  }
}

class FontSizes {
  int menuFontSize = 13;
  int editorFontSize = 15;
}
