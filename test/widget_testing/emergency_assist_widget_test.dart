import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qudra_0/Feature/emergency_assist/models/emergency_contact_model.dart';
import 'package:qudra_0/Feature/emergency_assist/presentation/permission_empty_states_view.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_circle_section.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_direct_services_row.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_location_status_card.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_profile_intro_card.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_quick_needs_wrap.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_segmented_selector.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_sos_button.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_sos_countdown_circle.dart';
import 'package:qudra_0/Feature/emergency_assist/widgets/emergency_switch_tile.dart';

import '../emergency_assist_test/unit/Test_helpers.dart';

void main() {
  group('Widget › PermissionEmptyStatesView', () {
    // This test increases the surface size to avoid overflow in the tall permission screen.
    testWidgets('renders permission empty state content', (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await pumpEmergencyAssistWidget(
        tester,
        child: PermissionEmptyStatesView(
          isLoading: false,
          helperMessage: 'Location service is disabled on the device.',
          onEnableLocationPressed: () {},
          onSkipPressed: () {},
          onOpenLocationSettingsPressed: () {},
          showOpenLocationSettingsButton: true,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Qudra'), findsOneWidget);
      expect(find.textContaining('Location permission'), findsOneWidget);
      expect(find.text('Enable location permission'), findsOneWidget);
      expect(find.text('Open location settings'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });
  });

  group('Widget › EmergencyLocationStatusCard', () {
    // This test verifies the ready location state text appears.
    testWidgets('renders ready location state', (tester) async {
      await pumpEmergencyAssistWidget(
        tester,
        child: const EmergencyLocationStatusCard(
          isLocationServiceEnabled: true,
          isLocationPermissionGranted: true,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Location is ready to share'), findsOneWidget);
    });

    // This test verifies the not-ready location state text appears.
    testWidgets('renders not ready location state', (tester) async {
      await pumpEmergencyAssistWidget(
        tester,
        child: const EmergencyLocationStatusCard(
          isLocationServiceEnabled: false,
          isLocationPermissionGranted: false,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Location is not ready right now'), findsOneWidget);
    });
  });

  group('Widget › EmergencyDirectServicesRow', () {
    // This test verifies all direct service callbacks are triggered.
    testWidgets('calls police ambulance and fire callbacks', (tester) async {
      int policeCalls = 0;
      int ambulanceCalls = 0;
      int fireCalls = 0;

      await pumpEmergencyAssistWidget(
        tester,
        child: EmergencyDirectServicesRow(
          onPolicePressed: () => policeCalls++,
          onAmbulancePressed: () => ambulanceCalls++,
          onFirePressed: () => fireCalls++,
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Police'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ambulance'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fire Dept.'));
      await tester.pumpAndSettle();

      expect(policeCalls, 1);
      expect(ambulanceCalls, 1);
      expect(fireCalls, 1);
    });
  });

  group('Widget › EmergencyQuickNeedsWrap', () {
    // This test verifies quick need chips render and callback fires.
    testWidgets('renders chips and toggles selected need', (tester) async {
      String? lastToggled;

      await pumpEmergencyAssistWidget(
        tester,
        child: EmergencyQuickNeedsWrap(
          quickNeeds: const [
            'quick_need_in_danger',
            'quick_need_medical_case',
          ],
          selectedQuickNeeds: const {},
          onToggle: (value) => lastToggled = value,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quick Needs'), findsOneWidget);
      expect(find.text('I am in danger'), findsOneWidget);

      await tester.tap(find.text('I am in danger'));
      await tester.pumpAndSettle();

      expect(lastToggled, 'quick_need_in_danger');
    });
  });

  group('Widget › EmergencySegmentedSelector', () {
    // This test verifies segmented selector callback is triggered.
    testWidgets('changes selected value on tap', (tester) async {
      String currentValue = 'text';

      await pumpEmergencyAssistWidget(
        tester,
        child: StatefulBuilder(
          builder: (context, setState) {
            return EmergencySegmentedSelector<String>(
              selectedValue: currentValue,
              onChanged: (value) {
                setState(() {
                  currentValue = value;
                });
              },
              options: const [
                EmergencySegmentedOption<String>(
                  value: 'text',
                  label: 'Text',
                ),
                EmergencySegmentedOption<String>(
                  value: 'voice',
                  label: 'Voice',
                ),
              ],
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();

      expect(currentValue, 'voice');
    });
  });

  group('Widget › EmergencySwitchTile', () {
    // This test verifies switch tile callback works.
    testWidgets('calls onChanged when switch is tapped', (tester) async {
      bool? latestValue;

      await pumpEmergencyAssistWidget(
        tester,
        child: EmergencySwitchTile(
          title: 'Enable vibration on alert',
          subtitle: 'Strong tactile response during emergency situations',
          value: true,
          onChanged: (value) => latestValue = value,
        ),
      );

      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(latestValue, false);
    });
  });

  group('Widget › EmergencySosCountdownCircle', () {
    // This test verifies countdown label and SOS are rendered.
    testWidgets('renders countdown label and SOS text', (tester) async {
      await pumpEmergencyAssistWidget(
        tester,
        child: const EmergencySosCountdownCircle(
          progress: 0.5,
          label: '2',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
    });
  });

  group('Widget › EmergencyProfileIntroCard', () {
    // This test verifies intro card localized content appears.
    testWidgets('renders intro card title and subtitle', (tester) async {
      await pumpEmergencyAssistWidget(
        tester,
        child: const EmergencyProfileIntroCard(),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Your life-saving'), findsOneWidget);
    });
  });

  group('Widget › EmergencyCircleSection', () {
    // This test verifies the empty state renders when there are no contacts.
    testWidgets('shows empty state when no contacts exist', (tester) async {
      await pumpEmergencyAssistWidget(
        tester,
        child: EmergencyCircleSection(
          contacts: const [],
          onAddContactsPressed: () {},
          onCallContactPressed: (_) {},
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Emergency Circle'), findsOneWidget);
      expect(find.text('No emergency contacts yet'), findsOneWidget);
    });

    // This test verifies contact preview appears when contacts exist.
    testWidgets('shows preview contacts when contacts exist', (tester) async {
      final contacts = <EmergencyContactModel>[
        makeEmergencyContact(
          name: 'Ali',
          relation: 'Brother',
          isPrimary: true,
        ),
        makeEmergencyContact(
          localId: 2,
          name: 'Mona',
          relation: 'Friend',
          isPrimary: false,
        ),
      ];

      await pumpEmergencyAssistWidget(
        tester,
        child: EmergencyCircleSection(
          contacts: contacts,
          onAddContactsPressed: () {},
          onCallContactPressed: (_) {},
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ali'), findsOneWidget);
      expect(find.text('Mona'), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
    });
  });

  group('Widget › EmergencySosButton', () {
    // This test avoids pumpAndSettle because the SOS button has an infinite repeating pulse animation.
    testWidgets('renders SOS button and hold hint', (tester) async {
      await pumpEmergencyAssistWidget(
        tester,
        child: EmergencySosButton(
          onLongPress: () {},
        ),
      );

      // This short pump lets the first frame render without waiting for the infinite animation.
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('SOS'), findsOneWidget);
      expect(find.text('Press and hold to activate'), findsOneWidget);
    });
  });
}