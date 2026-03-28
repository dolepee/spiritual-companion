import 'package:flutter/services.dart';

import 'app_preferences_service.dart';

class VibrationService {
  static Future<void> vibrate() async {
    if (!AppPreferencesService.hapticsEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Vibration not available or failed
    }
  }

  static Future<void> vibrateHeavy() async {
    if (!AppPreferencesService.hapticsEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Vibration not available or failed
    }
  }

  static Future<void> vibrateMedium() async {
    if (!AppPreferencesService.hapticsEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Vibration not available or failed
    }
  }
}
