class SettingsService {
  static SettingsService? _instance;
  String username = 'bez nazwy';

  SettingsService._();

  factory SettingsService() {
    _instance ??= SettingsService._();
    return _instance!;
  }
}
