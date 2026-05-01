import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../viewmodel/emergency_main_viewmodel.dart';
import '../widgets/emergency_circle_section.dart';
import '../widgets/emergency_direct_services_row.dart';
import '../widgets/emergency_location_status_card.dart';
import '../widgets/emergency_quick_needs_wrap.dart';
import '../widgets/emergency_sos_button.dart';

class EmergencyMainView extends StatefulWidget {
  const EmergencyMainView({
    super.key,
    required this.viewModel,
    this.onOpenContactsPressed,
    this.onOpenSosFlowPressed,
    this.onOpenSettingsPressed,
  });

  final EmergencyMainViewModel viewModel;
  final Future<void> Function()? onOpenContactsPressed;
  final VoidCallback? onOpenSosFlowPressed;
  final Future<void> Function()? onOpenSettingsPressed;

  @override
  State<EmergencyMainView> createState() => _EmergencyMainViewState();
}

class _EmergencyMainViewState extends State<EmergencyMainView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadData();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final vm = widget.viewModel;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              // This screen title reuses the existing emergency help localization key.
              context.tr('emergency_help'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  if (widget.onOpenSettingsPressed != null) {
                    await widget.onOpenSettingsPressed!();
                  } else {
                    // This fallback snackbar message is localized.
                    _showSnackBar(
                      context.tr('emergency_profile_setup_not_linked'),
                    );
                  }
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: vm.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                EmergencyLocationStatusCard(
                  isLocationServiceEnabled: vm.isLocationServiceEnabled,
                  isLocationPermissionGranted:
                  vm.isLocationPermissionGranted,
                ),
                const SizedBox(height: 24),
                Center(
                  child: EmergencySosButton(
                    onLongPress: () {
                      if (widget.onOpenSosFlowPressed != null) {
                        widget.onOpenSosFlowPressed!();
                      } else {
                        // This fallback snackbar message is localized.
                        _showSnackBar(
                          context.tr('emergency_sos_not_linked'),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 28),
                EmergencyDirectServicesRow(
                  onPolicePressed: () async {
                    await vm.callPolice();
                  },
                  onAmbulancePressed: () async {
                    await vm.callAmbulance();
                  },
                  onFirePressed: () async {
                    await vm.callFire();
                  },
                ),
                const SizedBox(height: 28),
                EmergencyQuickNeedsWrap(
                  quickNeeds: vm.quickNeeds,
                  selectedQuickNeeds: vm.selectedQuickNeeds,
                  onToggle: vm.toggleQuickNeed,
                ),
                const SizedBox(height: 28),
                EmergencyCircleSection(
                  contacts: vm.contacts,
                  onAddContactsPressed: () async {
                    if (widget.onOpenContactsPressed != null) {
                      await widget.onOpenContactsPressed!();
                    } else {
                      // This fallback snackbar message is localized.
                      _showSnackBar(
                        context.tr('emergency_contacts_not_linked'),
                      );
                    }
                  },
                  onCallContactPressed: (phoneNumber) async {
                    await vm.callContact(phoneNumber);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
