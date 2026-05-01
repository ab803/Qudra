import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../models/emergency_profile_model.dart';
import '../viewmodel/emergency_profile_setup_viewmodel.dart';
import '../widgets/emergency_labeled_field.dart';
import '../widgets/emergency_profile_intro_card.dart';
import '../widgets/emergency_segmented_selector.dart';
import '../widgets/emergency_switch_tile.dart';

class EmergencyProfileSetupView extends StatefulWidget {
  const EmergencyProfileSetupView({
    super.key,
    required this.viewModel,
    this.onSavedSuccessfully,
  });

  final EmergencyProfileSetupViewModel viewModel;
  final Future<void> Function()? onSavedSuccessfully;

  @override
  State<EmergencyProfileSetupView> createState() =>
      _EmergencyProfileSetupViewState();
}

class _EmergencyProfileSetupViewState
    extends State<EmergencyProfileSetupView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadInitialData();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
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
              // This title is localized for the emergency profile setup screen.
              context.tr('emergency_profile_setup_title'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          body: SafeArea(
            child: vm.isLoading && !vm.hasLoadedInitialData
                ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                const EmergencyProfileIntroCard(),
                const SizedBox(height: 24),
                EmergencyLabeledField(
                  label: context.tr('full_name'),
                  isRequired: true,
                  errorText: vm.fullNameError == null
                      ? null
                      : context.tr(vm.fullNameError!),
                  child: TextField(
                    controller: vm.fullNameController,
                    onChanged: (_) {
                      if (vm.fullNameError != null) {
                        vm.fullNameError = null;
                        vm.notifyListeners();
                      }
                    },
                    decoration: _inputDecoration(
                      context,
                      // This hint is localized for the full name field.
                      hintText:
                      context.tr('emergency_profile_full_name_hint'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                EmergencyLabeledField(
                  label: context.tr('disability_type'),
                  isRequired: true,
                  errorText: vm.disabilityTypeError == null
                      ? null
                      : context.tr(vm.disabilityTypeError!),
                  child: DropdownButtonFormField<String>(
                    value: vm.selectedDisabilityType,
                    items: vm.disabilityTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(context.tr(type)),
                      ),
                    )
                        .toList(),
                    onChanged: vm.updateDisabilityType,
                    decoration: _inputDecoration(
                      context,
                      // This hint is localized for selecting disability type.
                      hintText: context.tr('select_disability_type'),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurface.withOpacity(0.72),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                EmergencyLabeledField(
                  label: context.tr('emergency_blood_type'),
                  isRequired: true,
                  errorText: vm.bloodTypeError == null
                      ? null
                      : context.tr(vm.bloodTypeError!),
                  child: DropdownButtonFormField<String>(
                    value: vm.selectedBloodType,
                    items: vm.bloodTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ),
                    )
                        .toList(),
                    onChanged: vm.updateBloodType,
                    decoration: _inputDecoration(
                      context,
                      // This hint is localized for selecting blood type.
                      hintText: context.tr('emergency_select_blood_type'),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurface.withOpacity(0.72),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                EmergencyLabeledField(
                  label: context.tr('emergency_preferred_communication'),
                  child: EmergencySegmentedSelector<
                      EmergencyCommunicationMethod>(
                    selectedValue: vm.selectedCommunicationMethod,
                    onChanged: vm.updateCommunicationMethod,
                    // This options list uses localized labels for communication methods.
                    options: [
                      EmergencySegmentedOption(
                        value: EmergencyCommunicationMethod.text,
                        label: context.tr('emergency_communication_text'),
                      ),
                      EmergencySegmentedOption(
                        value: EmergencyCommunicationMethod.signLanguage,
                        label: context.tr('emergency_communication_sign'),
                      ),
                      EmergencySegmentedOption(
                        value: EmergencyCommunicationMethod.voice,
                        label: context.tr('emergency_communication_voice'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                EmergencyLabeledField(
                  label: context.tr('emergency_important_medical_notes'),
                  child: TextField(
                    controller: vm.medicalNotesController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: _inputDecoration(
                      context,
                      // This hint is localized for important medical notes.
                      hintText:
                      context.tr('emergency_medical_notes_hint'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                EmergencyLabeledField(
                  label: context.tr('emergency_allergies_medications'),
                  child: TextField(
                    controller: vm.allergiesAndMedicationsController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: _inputDecoration(
                      context,
                      // This hint is localized for allergies and medications.
                      hintText: context.tr('emergency_allergies_hint'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          // This notice is localized for local-only data storage.
                          context.tr('emergency_profile_local_save_notice'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                            colorScheme.onSurface.withOpacity(0.72),
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                EmergencySwitchTile(
                  // This title is localized for vibration alert setting.
                  title: context.tr('emergency_vibration_alert_title'),
                  // This subtitle is localized for vibration alert setting.
                  subtitle:
                  context.tr('emergency_vibration_alert_subtitle'),
                  value: vm.vibrationOnAlert,
                  onChanged: vm.updateVibrationOnAlert,
                ),
                const SizedBox(height: 20),
                if (vm.submitError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(
                        theme.brightness == Brightness.dark
                            ? 0.14
                            : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.error.withOpacity(0.18),
                      ),
                    ),
                    child: Text(
                      context.tr(vm.submitError!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                      final saved = await vm.saveProfile();
                      if (!mounted) return;
                      if (!saved) return;
                      if (widget.onSavedSuccessfully != null) {
                        await widget.onSavedSuccessfully!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: vm.isLoading
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      // This button label is localized for saving profile data.
                      vm.isLoading
                          ? context.tr('emergency_saving')
                          : context.tr('save_changes'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, {
        required String hintText,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.45),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.2,
        ),
      ),
    );
  }
}