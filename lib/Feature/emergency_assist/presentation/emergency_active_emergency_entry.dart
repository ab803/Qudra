import 'package:flutter/material.dart';

import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';
import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';
import '../services/emergency_share_service.dart';
import '../services/emergency_whatsapp_service.dart';
import '../viewmodel/emergency_active_emergency_viewmodel.dart';
import 'emergency_active_emergency_view.dart';
import 'emergency_profile_card_entry.dart';

class EmergencyActiveEmergencyEntry extends StatelessWidget {
  const EmergencyActiveEmergencyEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = EmergencyActiveEmergencyViewModel(
      profileService: EmergencyProfileService(),
      contactsService: EmergencyContactsService(),
      locationService: EmergencyLocationService(),
      dialerService: EmergencyDialerService(),
      shareService: EmergencyShareService(),
      whatsappService: EmergencyWhatsAppService(),
    );

    return EmergencyActiveEmergencyView(
      viewModel: viewModel,
      onOpenEmergencyCardPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const EmergencyProfileCardEntry(),
          ),
        );
      },
      onImSafePressed: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}