import 'package:flutter/material.dart';
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
                      'Add Reminder',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter medicine name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: subCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dose / Notes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter dose / notes';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(timeText ?? 'Pick Time'),
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
                              timeError = 'Please choose a reminder time';
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
                        child: const Text(
                          'Save',
                          style: TextStyle(
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
