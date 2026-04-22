import 'package:flutter/material.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final vm = widget.viewModel;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'إعداد الملف الشخصي للطوارئ',
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
                    label: 'الاسم الكامل',
                    isRequired: true,
                    errorText: vm.fullNameError,
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
                        hintText: 'أدخل اسمك كما في الهوية',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  EmergencyLabeledField(
                    label: 'نوع الإعاقة',
                    isRequired: true,
                    errorText: vm.disabilityTypeError,
                    child: DropdownButtonFormField<String>(
                      value: vm.selectedDisabilityType,
                      items: vm.disabilityTypes
                          .map(
                            (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      )
                          .toList(),
                      onChanged: vm.updateDisabilityType,
                      decoration: _inputDecoration(
                        context,
                        hintText: 'اختر نوع الإعاقة',
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurface.withOpacity(0.72),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  EmergencyLabeledField(
                    label: 'فصيلة الدم',
                    isRequired: true,
                    errorText: vm.bloodTypeError,
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
                        hintText: 'اختر فصيلة الدم',
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurface.withOpacity(0.72),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  EmergencyLabeledField(
                    label: 'طريقة التواصل المفضلة',
                    child: EmergencySegmentedSelector<
                        EmergencyCommunicationMethod>(
                      selectedValue: vm.selectedCommunicationMethod,
                      onChanged: vm.updateCommunicationMethod,
                      options: const [
                        EmergencySegmentedOption(
                          value: EmergencyCommunicationMethod.text,
                          label: 'كتابة',
                        ),
                        EmergencySegmentedOption(
                          value:
                          EmergencyCommunicationMethod.signLanguage,
                          label: 'لغة إشارة',
                        ),
                        EmergencySegmentedOption(
                          value: EmergencyCommunicationMethod.voice,
                          label: 'صوت',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  EmergencyLabeledField(
                    label: 'ملاحظات طبية هامة',
                    child: TextField(
                      controller: vm.medicalNotesController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: _inputDecoration(
                        context,
                        hintText:
                        'أي حالات طبية مزمنة أو معلومات ضرورية للمساعدة...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  EmergencyLabeledField(
                    label: 'الحساسية والأدوية',
                    child: TextField(
                      controller: vm.allergiesAndMedicationsController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: _inputDecoration(
                        context,
                        hintText:
                        'قائمة بالحساسية من أطعمة أو أدوية، والأدوية الحالية...',
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
                            'يتم حفظ هذه البيانات محليًا على هذا الجهاز فقط لاستخدامها أثناء الطوارئ.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.72),
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
                    title: 'تفعيل الاهتزاز عند التنبيه',
                    subtitle: 'استجابة لمسية قوية أثناء حالات الطوارئ',
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
                        vm.submitError!,
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
                        vm.isLoading ? 'جاري الحفظ...' : 'حفظ البيانات',
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
      ),
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