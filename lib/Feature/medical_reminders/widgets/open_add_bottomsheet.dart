import 'package:flutter/material.dart';
import '../../../core/Services/Localization/translation_extension.dart';
import '../models/reminder_model.dart';

Future<ReminderModel?> openAddBottomSheet(BuildContext context) async {
  final titleCtrl = TextEditingController();
  final subCtrl = TextEditingController();
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;

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

          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomInset + 16,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // This bottom sheet title is localized for adding a reminder.
                      ctx.tr('add_reminder'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        // This input label is localized for medicine name.
                        labelText: ctx.tr('medicine_name'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          // This validation message is localized for medicine name.
                          return ctx.tr('enter_medicine_name');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: subCtrl,
                      decoration: InputDecoration(
                        // This input label is localized for dose or notes.
                        labelText: ctx.tr('dose_notes'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          // This validation message is localized for dose or notes.
                          return ctx.tr('enter_dose_notes');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        // This button label is localized for picking time unless a time is already selected.
                        timeText ?? ctx.tr('pick_time'),
                      ),
                    ),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: colorScheme.primary,
                          disabledForegroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final isValid = formKey.currentState?.validate() ?? false;
                          if (!isValid) return;

                          if (timeText == null || timeText!.trim().isEmpty) {
                            setState(() {
                              // This validation message is localized for choosing a reminder time.
                              timeError = ctx.tr('choose_time');
                            });
                            return;
                          }

                          final id =
                          DateTime.now().microsecondsSinceEpoch.toString();
                          final model = ReminderModel(
                            id: id,
                            title: titleCtrl.text.trim(),
                            subtitle: subCtrl.text.trim(),
                            time: timeText!,
                            isEnabled: true,
                          );

                          Navigator.of(ctx).pop(model);
                        },
                        child: Text(
                          // This button label is localized for saving the reminder.
                          ctx.tr('save'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
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

  await Future.delayed(const Duration(milliseconds: 300));
  titleCtrl.dispose();
  subCtrl.dispose();
  return result;
}