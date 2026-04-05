import 'package:flutter/material.dart';

import '../services/emergency_profile_service.dart';
import '../viewmodel/emergency_profile_setup_viewmodel.dart';
import 'emergency_profile_setup_view.dart';

class EmergencyProfileSetupEntry extends StatelessWidget {
  const EmergencyProfileSetupEntry({
    super.key,
    this.onSavedSuccessfully,
  });

  final Future<void> Function()? onSavedSuccessfully;

  @override
  Widget build(BuildContext context) {
    final service = EmergencyProfileService();
    final viewModel = EmergencyProfileSetupViewModel(
      profileService: service,
    );

    return EmergencyProfileSetupView(
      viewModel: viewModel,
      onSavedSuccessfully: () async {
        if (onSavedSuccessfully != null) {
          await onSavedSuccessfully!();
        } else {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          }
        }
      },
    );
  }
}