import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:qudra_0/Feature/emergency_assist/presentation/emergency_profile_setup_view.dart';
import 'package:qudra_0/Feature/emergency_assist/viewmodel/emergency_profile_setup_viewmodel.dart';

import 'unit/Test_helpers.dart';

void main() {
  // This binding enables integration test execution.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // This setup registers fallback values used by mocktail.
  setUpAll(() {
    registerEmergencyAssistFallbackValues();
  });

  group('Integration › Emergency Assist', () {
    // This test verifies the user can complete the emergency profile setup flow successfully.
    testWidgets('user completes emergency profile setup successfully',
            (tester) async {
          final profileService = MockEmergencyProfileService();
          bool savedCallbackCalled = false;

          // This mock returns no existing profile so the form starts empty.
          when(() => profileService.getProfile()).thenAnswer((_) async => null);

          // This mock accepts saving the profile successfully.
          when(() => profileService.saveProfile(any())).thenAnswer((_) async {});

          final viewModel = EmergencyProfileSetupViewModel(
            profileService: profileService,
          );

          await tester.pumpWidget(
            buildEmergencyAssistTestApp(
              child: EmergencyProfileSetupView(
                viewModel: viewModel,
                onSavedSuccessfully: () async {
                  savedCallbackCalled = true;
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          // This enters the required full name.
          await tester.enterText(find.byType(TextField).first, 'Ahmed Ayman');
          await tester.pumpAndSettle();

          // This opens the disability type dropdown and selects Hearing.
          await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Hearing').last);
          await tester.pumpAndSettle();

          // This opens the blood type dropdown and selects O+.
          await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
          await tester.pumpAndSettle();
          await tester.tap(find.text('O+').last);
          await tester.pumpAndSettle();

          // This scrolls until the save button becomes visible.
          final saveButtonFinder = find.text('Save Changes');
          await tester.scrollUntilVisible(
            saveButtonFinder,
            300,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();

          // This taps the save button after ensuring it is visible.
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          expect(savedCallbackCalled, true);

          // This verifies the profile service save method was called once.
          verify(() => profileService.saveProfile(any())).called(1);
        });
  });
}

