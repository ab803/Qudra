import 'package:flutter/material.dart';

import '../../../core/Services/Localization/translation_extension.dart';
import '../models/reminder_model.dart';

// This function opens the Care Plans bottom sheet and returns a configured ReminderModel.
Future<ReminderModel?> openAddBottomSheet(BuildContext context) async {
  final titleCtrl = TextEditingController();
  final subCtrl = TextEditingController();

  // This value stores the selected reminder or care plan type.
  CarePlanType selectedType = CarePlanType.medication;

  String? timeText;
  String? timeError;

  final formKey = GlobalKey<FormState>();

  final ReminderModel? result = await showModalBottomSheet<ReminderModel>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor:
    Theme.of(context).bottomSheetTheme.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

          // This helper opens the native time picker and stores the selected HH:mm value.
          Future<void> pickTime() async {
            final picked = await showTimePicker(
              context: ctx,
              initialTime: TimeOfDay.now(),
            );

            if (picked != null) {
              final hh = picked.hour.toString().padLeft(2, '0');
              final mm = picked.minute.toString().padLeft(2, '0');

              setState(() {
                timeText = '$hh:$mm';
                timeError = null;
              });
            }
          }

          // This helper returns the localized bottom sheet title.
          String sheetTitle() {
            return ctx.tr('add_care_plan_item');
          }

          // This helper returns the title field label based on the selected care plan type.
          String titleLabel() {
            switch (selectedType) {
              case CarePlanType.medication:
                return ctx.tr('medicine_name');
              case CarePlanType.feeding:
                return ctx.tr('feeding_title_label');
              case CarePlanType.rehab:
                return ctx.tr('rehab_title_label');
              case CarePlanType.learning:
                return ctx.tr('learning_title_label');
            }
          }

          // This helper returns the title validation message based on the selected care plan type.
          String titleValidationMessage() {
            switch (selectedType) {
              case CarePlanType.medication:
                return ctx.tr('enter_medicine_name');
              case CarePlanType.feeding:
                return ctx.tr('enter_feeding_title');
              case CarePlanType.rehab:
                return ctx.tr('enter_rehab_title');
              case CarePlanType.learning:
                return ctx.tr('enter_learning_title');
            }
          }

          // This helper returns the notes field label based on the selected care plan type.
          String notesLabel() {
            switch (selectedType) {
              case CarePlanType.medication:
                return ctx.tr('dose_notes');
              case CarePlanType.feeding:
                return ctx.tr('feeding_guidance');
              case CarePlanType.rehab:
                return ctx.tr('rehab_notes');
              case CarePlanType.learning:
                return ctx.tr('learning_goal_details');
            }
          }

          // This helper returns the notes validation message based on the selected care plan type.
          String notesValidationMessage() {
            switch (selectedType) {
              case CarePlanType.medication:
                return ctx.tr('enter_dose_notes');
              case CarePlanType.feeding:
                return ctx.tr('enter_feeding_guidance');
              case CarePlanType.rehab:
                return ctx.tr('enter_rehab_notes');
              case CarePlanType.learning:
                return ctx.tr('enter_learning_goal_details');
            }
          }

          // This helper returns a safe general disclaimer for feeding guidance.
          String? typeDisclaimer() {
            if (selectedType == CarePlanType.feeding) {
              return ctx.tr('general_feeding_disclaimer');
            }

            if (selectedType == CarePlanType.rehab) {
              return ctx.tr('general_rehab_disclaimer');
            }

            return null;
          }

          // This helper clears inputs when the user changes the type to avoid confusing labels.
          void updateSelectedType(CarePlanType type) {
            setState(() {
              selectedType = type;
              titleCtrl.clear();
              subCtrl.clear();
              timeError = null;
            });
          }

          // This helper validates the form and closes the bottom sheet with a ReminderModel.
          void submit() {
            final isValid = formKey.currentState?.validate() ?? false;
            if (!isValid) return;

            if (timeText == null || timeText!.trim().isEmpty) {
              setState(() {
                // This validation message is localized for choosing a care plan time.
                timeError = ctx.tr('choose_time');
              });
              return;
            }

            final id = DateTime.now().microsecondsSinceEpoch.toString();

            // This model stores the selected type so the same reminder system can support care plans.
            final model = ReminderModel(
              id: id,
              title: titleCtrl.text.trim(),
              subtitle: subCtrl.text.trim(),
              time: timeText!,
              isEnabled: true,
              type: selectedType,
            );

            Navigator.of(ctx).pop(model);
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 18,
              bottom: bottomInset + 18,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // This title identifies the bottom sheet as the entry point for Care Plans.
                    Text(
                      sheetTitle(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // This subtitle explains that the user can add medication, feeding, rehab, or learning items.
                    Text(
                      ctx.tr('add_care_plan_item_subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.68),
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // This section lets the user choose the care plan item type.
                    _CarePlanTypeSelector(
                      selectedType: selectedType,
                      onChanged: updateSelectedType,
                    ),
                    const SizedBox(height: 18),

                    // This optional disclaimer appears for guidance-like plan types.
                    if (typeDisclaimer() != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(
                            theme.brightness == Brightness.dark ? 0.14 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.18),
                          ),
                        ),
                        child: Text(
                          typeDisclaimer()!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // This field captures the item title such as medicine name, meal reminder, exercise, or learning goal.
                    TextFormField(
                      controller: titleCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: titleLabel(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return titleValidationMessage();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // This field captures dose notes, feeding guidance, rehab notes, or learning goal details.
                    TextFormField(
                      controller: subCtrl,
                      minLines: 2,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: notesLabel(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return notesValidationMessage();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // This button opens the time picker for the daily reminder time.
                    OutlinedButton.icon(
                      onPressed: pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        timeText ?? ctx.tr('pick_time'),
                      ),
                    ),

                    // This block shows the time validation error when no time is selected.
                    if (timeError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        timeError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // This button saves the configured care plan item.
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: colorScheme.primary,
                          disabledForegroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: submit,
                        child: Text(
                          ctx.tr('save'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  // This delay keeps controller disposal safe after the bottom sheet animation finishes.
  await Future.delayed(const Duration(milliseconds: 300));

  titleCtrl.dispose();
  subCtrl.dispose();

  return result;
}

// This widget renders selectable chips for Medication, Feeding, Rehabilitation, and Learning.
class _CarePlanTypeSelector extends StatelessWidget {
  final CarePlanType selectedType;
  final ValueChanged<CarePlanType> onChanged;

  const _CarePlanTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = const [
      CarePlanType.medication,
      CarePlanType.feeding,
      CarePlanType.rehab,
      CarePlanType.learning,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((type) {
        final isSelected = selectedType == type;

        return _CarePlanTypeChip(
          type: type,
          isSelected: isSelected,
          onTap: () => onChanged(type),
        );
      }).toList(),
    );
  }
}

// This widget renders one selectable care plan type chip.
class _CarePlanTypeChip extends StatelessWidget {
  final CarePlanType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _CarePlanTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  // This helper returns the localized label key for each care plan type.
  String _labelKey(CarePlanType type) {
    switch (type) {
      case CarePlanType.medication:
        return 'plan_type_medication';
      case CarePlanType.feeding:
        return 'plan_type_feeding';
      case CarePlanType.rehab:
        return 'plan_type_rehab';
      case CarePlanType.learning:
        return 'plan_type_learning';
    }
  }

  // This helper returns the visual icon for each care plan type.
  IconData _icon(CarePlanType type) {
    switch (type) {
      case CarePlanType.medication:
        return Icons.medication_outlined;
      case CarePlanType.feeding:
        return Icons.restaurant_outlined;
      case CarePlanType.rehab:
        return Icons.fitness_center_outlined;
      case CarePlanType.learning:
        return Icons.school_outlined;
    }
  }

  // This helper returns the accent color for each care plan type.
  Color _accentColor(CarePlanType type) {
    switch (type) {
      case CarePlanType.medication:
        return const Color(0xFF22C55E);
      case CarePlanType.feeding:
        return const Color(0xFFF97316);
      case CarePlanType.rehab:
        return const Color(0xFF3B82F6);
      case CarePlanType.learning:
        return const Color(0xFFA855F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _accentColor(type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.20 : 0.12,
            )
                : theme.cardColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? accentColor : theme.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon(type),
                size: 18,
                color: isSelected
                    ? accentColor
                    : colorScheme.onSurface.withOpacity(0.68),
              ),
              const SizedBox(width: 7),
              Text(
                context.tr(_labelKey(type)),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? accentColor
                      : colorScheme.onSurface.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}