import 'package:flutter/material.dart';

import '../viewmodel/emergency_sos_activation_viewmodel.dart';
import 'emergency_active_emergency_entry.dart';
import 'emergency_sos_activation_view.dart';

class EmergencySosActivationEntry extends StatelessWidget {
  const EmergencySosActivationEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = EmergencySosActivationViewModel();

    return EmergencySosActivationView(
      viewModel: viewModel,
      onCompleted: () async {
        if (!context.mounted) return;

        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const EmergencyActiveEmergencyEntry(),
          ),
        );
      },
    );
  }
}