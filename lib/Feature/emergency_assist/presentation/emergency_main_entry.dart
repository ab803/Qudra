import 'package:flutter/material.dart';

import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';
import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';
import '../viewmodel/emergency_contacts_viewmodel.dart';
import '../viewmodel/emergency_main_viewmodel.dart';
import 'emergency_contacts_view.dart';
import 'emergency_main_view.dart';
import 'emergency_profile_setup_entry.dart';
import 'emergency_sos_activation_entry.dart';

class EmergencyMainEntry extends StatefulWidget {
  const EmergencyMainEntry({super.key});

  @override
  State<EmergencyMainEntry> createState() => _EmergencyMainEntryState();
}

class _EmergencyMainEntryState extends State<EmergencyMainEntry> {
  late final EmergencyMainViewModel _mainViewModel;

  @override
  void initState() {
    super.initState();

    _mainViewModel = EmergencyMainViewModel(
      profileService: EmergencyProfileService(),
      contactsService: EmergencyContactsService(),
      locationService: EmergencyLocationService(),
      dialerService: EmergencyDialerService(),
    );
  }

  @override
  void dispose() {
    _mainViewModel.dispose();
    super.dispose();
  }

  Future<void> _openContactsScreen() async {
    final contactsViewModel = EmergencyContactsViewModel(
      contactsService: EmergencyContactsService(),
      dialerService: EmergencyDialerService(),
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmergencyContactsView(
          viewModel: contactsViewModel,
        ),
      ),
    );

    await _mainViewModel.refreshData();
  }

  Future<void> _openSosActivationFlow() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencySosActivationEntry(),
      ),
    );

    await _mainViewModel.refreshData();
  }

  Future<void> _openProfileSettingsScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencyProfileSetupEntry(),
      ),
    );

    await _mainViewModel.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return EmergencyMainView(
      viewModel: _mainViewModel,
      onOpenContactsPressed: _openContactsScreen,
      onOpenSosFlowPressed: _openSosActivationFlow,
      onOpenSettingsPressed: _openProfileSettingsScreen,
    );
  }
}