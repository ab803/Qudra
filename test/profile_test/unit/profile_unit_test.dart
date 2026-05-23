import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qudra_0/core/Services/Localization/language_cubit.dart';
import 'package:qudra_0/core/Services/Localization/language_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // This initializes the Flutter binding for tests that use WidgetsBinding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Unit › LanguageState', () {
    // This test verifies LanguageInitial uses English locale by default.
    test('LanguageInitial starts with en locale', () {
      const state = LanguageInitial();

      expect(state.locale.languageCode, 'en');
    });

    // This test verifies LanguageChanged stores the provided locale.
    test('LanguageChanged stores provided locale', () {
      const state = LanguageChanged(Locale('ar'));

      expect(state.locale.languageCode, 'ar');
    });
  });

  group('Unit › LanguageCubit', () {
    // This test verifies the cubit falls back to the system locale when no value is saved.
    test('constructor falls back to system locale when no saved value exists',
            () async {
          SharedPreferences.setMockInitialValues({});

          final cubit = LanguageCubit();

          // This waits for the async constructor logic to finish.
          await Future<void>.delayed(Duration.zero);

          final systemCode =
              WidgetsBinding.instance.platformDispatcher.locale.languageCode;

          expect(cubit.state.locale.languageCode, systemCode);

          await cubit.close();
        });

    // This test verifies the cubit restores Arabic when it is already saved.
    test('constructor restores saved ar locale', () async {
      SharedPreferences.setMockInitialValues({
        'app_language': 'ar',
      });

      final cubit = LanguageCubit();

      // This waits for the async constructor logic to finish.
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.locale.languageCode, 'ar');

      await cubit.close();
    });

    // This test verifies changeLanguage updates the state and preference to English.
    test('changeLanguage updates locale to en', () async {
      SharedPreferences.setMockInitialValues({});

      final cubit = LanguageCubit();

      // This waits for the async constructor logic to finish.
      await Future<void>.delayed(Duration.zero);

      await cubit.changeLanguage('en');

      expect(cubit.state.locale.languageCode, 'en');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'en');

      await cubit.close();
    });

    // This test verifies changeLanguage updates the state and preference to Arabic.
    test('changeLanguage updates locale to ar', () async {
      SharedPreferences.setMockInitialValues({});

      final cubit = LanguageCubit();

      // This waits for the async constructor logic to finish.
      await Future<void>.delayed(Duration.zero);

      await cubit.changeLanguage('ar');

      expect(cubit.state.locale.languageCode, 'ar');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'ar');

      await cubit.close();
    });

    // This test verifies system mode stores "system" and emits the platform locale.
    test('changeLanguage system stores system and emits system locale',
            () async {
          SharedPreferences.setMockInitialValues({});

          final cubit = LanguageCubit();

          // This waits for the async constructor logic to finish.
          await Future<void>.delayed(Duration.zero);

          await cubit.changeLanguage('system');

          final systemCode =
              WidgetsBinding.instance.platformDispatcher.locale.languageCode;

          expect(cubit.state.locale.languageCode, systemCode);

          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('app_language'), 'system');

          await cubit.close();
        });
  });
}