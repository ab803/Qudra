import 'package:flutter/material.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;

          return Scaffold(
            backgroundColor: const Color(0xFFF6F7F9),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF6F7F9),
              elevation: 0,
              surfaceTintColor: const Color(0xFFF6F7F9),
              centerTitle: true,
              title: const Text(
                'المساعدة في الطوارئ',
                style: TextStyle(
                  color: Color(0xFF111827),
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
                      _showSnackBar(
                        'لم يتم ربط شاشة تعديل الملف الشخصي بعد.',
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  EmergencyLocationStatusCard(
                    isLocationServiceEnabled:
                    vm.isLocationServiceEnabled,
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
                          _showSnackBar(
                            'سيتم ربط مسار SOS لاحقًا.',
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
                        _showSnackBar(
                          'سيتم ربط شاشة جهات الاتصال لاحقًا.',
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
      ),
    );
  }
}