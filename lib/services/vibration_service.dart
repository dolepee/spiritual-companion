import 'package:flutter/services.dart';

class VibrationService {
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Vibration not available or failed
    }
  }

  static Future<void> vibrateHeavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Vibration not available or failed
    }
  }

  static Future<void> vibrateMedium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Vibration not available or failed
    }
  }
}