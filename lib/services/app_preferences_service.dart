import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  static const String _hapticsKey = 'app_haptics_enabled';

  static bool _hapticsEnabled = true;

  static bool get hapticsEnabled => _hapticsEnabled;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
  }

  static Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }
}
