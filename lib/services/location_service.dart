import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';

class LocationService {
  static Position? _currentPosition;
  static Coordinates? _coordinates;

  static Position? get currentPosition => _currentPosition;
  static Coordinates? get coordinates => _coordinates;

  static Future<void> initialize() async {
    await getCurrentLocation();
  }

  static Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('Location permissions are permanently denied');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _coordinates = Coordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (kDebugMode) {
        print('Location obtained: ${_coordinates!.latitude}, ${_coordinates!.longitude}');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting location: $e');
    }
  }

  static double getQiblaDirection() {
    if (_coordinates == null) return 0.0;

    final qibla = Qibla(_coordinates!);
    return qibla.direction;
  }
}