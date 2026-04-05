import 'package:flutter/material.dart';

import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';

enum EmergencyEntryStatus {
  loading,
  needProfileSetup,
  needLocationPermission,
  ready,
  error,
}

class EmergencyEntryViewModel extends ChangeNotifier {
  EmergencyEntryViewModel({
    required EmergencyProfileService profileService,
    required EmergencyLocationService locationService,
  })  : _profileService = profileService,
        _locationService = locationService;

  final EmergencyProfileService _profileService;
  final EmergencyLocationService _locationService;

  EmergencyEntryStatus status = EmergencyEntryStatus.loading;

  bool isRequestingPermission = false;
  bool isLocationServiceDisabled = false;
  String? errorMessage;
  String? permissionHelperMessage;

  Future<void> initialize() async {
    status = EmergencyEntryStatus.loading;
    errorMessage = null;
    permissionHelperMessage = null;
    isLocationServiceDisabled = false;
    notifyListeners();

    try {
      final hasCompletedSetup = await _profileService.hasCompletedSetup();

      if (!hasCompletedSetup) {
        status = EmergencyEntryStatus.needProfileSetup;
        notifyListeners();
        return;
      }

      final isLocationServiceEnabled =
      await _locationService.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        isLocationServiceDisabled = true;
        permissionHelperMessage =
        'خدمة الموقع مقفلة من الجهاز. فعّل الموقع أولًا للتمكن من مشاركة موقعك في الطوارئ.';
        status = EmergencyEntryStatus.needLocationPermission;
        notifyListeners();
        return;
      }

      isLocationServiceDisabled = false;
      permissionHelperMessage = null;

      final hasLocationPermission =
      await _locationService.isPermissionGranted();

      if (hasLocationPermission) {
        status = EmergencyEntryStatus.ready;
      } else {
        status = EmergencyEntryStatus.needLocationPermission;
      }

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('EmergencyEntry initialize error: $e');
      debugPrintStack(stackTrace: stackTrace);

      status = EmergencyEntryStatus.error;
      errorMessage = 'حدث خطأ أثناء تحميل بيانات الطوارئ.';
      notifyListeners();
    }
  }

  Future<void> refreshEntryFlow() async {
    await initialize();
  }

  Future<void> requestLocationPermission() async {
    isRequestingPermission = true;
    notifyListeners();

    try {
      final isLocationServiceEnabled =
      await _locationService.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        isLocationServiceDisabled = true;
        permissionHelperMessage =
        'خدمة الموقع مقفلة من الجهاز. افتح إعدادات الموقع ثم حاول مرة أخرى.';
        status = EmergencyEntryStatus.needLocationPermission;
        isRequestingPermission = false;
        notifyListeners();
        return;
      }

      isLocationServiceDisabled = false;
      permissionHelperMessage = null;

      final granted = await _locationService.requestLocationPermission();

      if (granted) {
        status = EmergencyEntryStatus.ready;
      } else {
        status = EmergencyEntryStatus.needLocationPermission;
        permissionHelperMessage =
        'لم يتم منح صلاحية الموقع بعد. يمكنك المحاولة مرة أخرى أو التخطي الآن.';
      }
    } catch (e, stackTrace) {
      debugPrint('EmergencyEntry request permission error: $e');
      debugPrintStack(stackTrace: stackTrace);

      status = EmergencyEntryStatus.error;
      errorMessage = 'تعذر الوصول إلى صلاحية الموقع.';
    }

    isRequestingPermission = false;
    notifyListeners();
  }

  void skipLocationForNow() {
    status = EmergencyEntryStatus.ready;
    notifyListeners();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettingsPage();
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettingsPage();
  }
}