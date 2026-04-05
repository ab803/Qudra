import 'package:geolocator/geolocator.dart';

class EmergencyLocationService {

  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.always ||
          requested == LocationPermission.whileInUse;
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return false;
  }

  Future<Position?> getCurrentPositionSafely() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    final hasPermission = await isPermissionGranted();
    if (!hasPermission) return null;

    try {
      // 1) حاول تجيب آخر موقع معروف أولًا لأنه أسرع جدًا
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }

      // 2) لو مفيش، هات موقع جديد لكن بدقة أقل علشان يكون أسرع
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      return null;
    }
  }

  String buildGoogleMapsUrl(Position position) {
    return 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
  }

  Future<void> openAppSettingsPage() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettingsPage() async {
    await Geolocator.openLocationSettings();
  }
}