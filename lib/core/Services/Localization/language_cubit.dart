import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  static const String _key = 'app_language';

  LanguageCubit() : super(const LanguageInitial()) {
    loadSavedLanguage();
  }

  /// ✅ Load saved language on app start
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);

    if (code == null || code == 'system') {
      // system language (default)
      final systemLocale =
          WidgetsBinding.instance.platformDispatcher.locale;
      emit(LanguageChanged(systemLocale));
    } else {
      emit(LanguageChanged(Locale(code)));
    }
  }

  /// ✅ Change language & save it
  Future<void> changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();

    if (code == 'system') {
      await prefs.setString(_key, 'system');

      final systemLocale =
          WidgetsBinding.instance.platformDispatcher.locale;

      emit(LanguageChanged(systemLocale));
    } else {
      await prefs.setString(_key, code);
      emit(LanguageChanged(Locale(code)));
    }
  }
}