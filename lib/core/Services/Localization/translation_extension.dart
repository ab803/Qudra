import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/LocalizationService.dart';


extension TranslateExtension on BuildContext {
  String tr(String key) {
    return AppLocalization.of(this).translate(key);
  }
}