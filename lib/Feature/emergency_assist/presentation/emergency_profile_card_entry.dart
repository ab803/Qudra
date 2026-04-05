import 'package:flutter/material.dart';

import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';
import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';
import '../services/emergency_share_service.dart';
import '../viewmodel/emergency_profile_card_viewmodel.dart';
import 'emergency_profile_card_view.dart';

class EmergencyProfileCardEntry extends StatelessWidget {
  const EmergencyProfileCardEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = EmergencyProfileCardViewModel(
      profileService: EmergencyProfileService(),
      contactsService: EmergencyContactsService(),
      locationService: EmergencyLocationService(),
      shareService: EmergencyShareService(),
      dialerService: EmergencyDialerService(),
    );

    return EmergencyProfileCardView(
      viewModel: viewModel,
    );
  }
}