import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// This import enables localized text access using context.tr().
import '../../../../core/Services/Localization/translation_extension.dart';
import '../../widgets/meds_header.dart';
import '../../widgets/meds_progress_card.dart';
import '../../widgets/meds_reminder_tile.dart';
import '../../widgets/meds_section_title.dart';
import '../../widgets/open_add_bottomsheet.dart';
import '../../models/reminder_model.dart';
import '../../viewmodel/medical_reminders_view_model.dart';

class MedicalRemindersView extends StatelessWidget {
  const MedicalRemindersView({super.key});

  String _formatTimeForUi(BuildContext context, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final tod = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    return MaterialLocalizations.of(context).formatTimeOfDay(tod);
  }

  ReminderViewData _toViewData(
      BuildContext context,
      MedicalRemindersViewModel vm,
      ReminderModel m,
      ) {
    final String? normalizedTime =
    m.time.trim().isEmpty ? null : _formatTimeForUi(context, m.time);

    return ReminderViewData(
      id: m.id,
      title: m.title,
      subtitle: m.subtitle,
      timeText: normalizedTime,
      isEnabled: m.isEnabled,
      statusLabel: vm.getStatusLabelForReminder(m.id),
    );
  }

  String _buildProgressFooter(
      BuildContext context,
      MedicalRemindersViewModel vm,
      ) {
    final int missed = vm.missedTodayCount;
    final String? nextRaw = vm.nextReminderTime;
    final String? nextFormatted =
    nextRaw == null ? null : _formatTimeForUi(context, nextRaw);

    if (missed > 0 && nextFormatted != null) {
      // This progress footer combines the localized missed label with the localized next reminder label.
      return '$missed ${context.tr('missed')} • ${context.tr('next_at')} $nextFormatted';
    }
    if (missed > 0) {
      // This progress footer shows the localized missed label only.
      return '$missed ${context.tr('missed')}';
    }
    if (nextFormatted != null) {
      // This progress footer shows the localized next reminder label only.
      return '${context.tr('next_at')} $nextFormatted';
    }
    if (vm.dueTodayCount == 0) {
      // This footer label is localized when no doses are scheduled.
      return context.tr('no_doses_scheduled');
    }
    if (vm.takenTodayCount >= vm.dueTodayCount) {
      // This footer label is localized when all doses are completed.
      return context.tr('all_doses_completed');
    }
    // This footer label is localized when there are no upcoming doses.
    return context.tr('no_upcoming_doses');
  }

  Future<void> _confirmDelete(
      BuildContext context,
      String id,
      String title,
      ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final vm = context.read<MedicalRemindersViewModel>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // This dialog title is localized for deleting a reminder.
        title: Text(context.tr('delete_reminder')),
        // This dialog message is localized and injects the reminder title.
        content: Text(
          context.tr('delete_reminder_confirm').replaceAll('{title}', title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            // This button label is localized for cancel action.
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              // This button label is localized for delete action.
              context.tr('delete'),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await vm.deleteReminder(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vm = context.watch<MedicalRemindersViewModel>();
    final items = vm.reminders.map((m) => _toViewData(context, vm, m)).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: vm.isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        )
            : ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            const MedsHeader(),
            const SizedBox(height: 14),
            MedsProgressCard(
              taken: vm.takenTodayCount,
              total: vm.dueTodayCount,
              // This caption is localized for completed doses.
              caption: context.tr('doses_completed'),
              footerText: _buildProgressFooter(context, vm),
              missedCount: vm.missedTodayCount,
            ),
            if (vm.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                // This error message is localized using the key stored in the view model.
                context.tr(vm.errorMessage!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 18),
            MedsSectionTitle(
              icon: Icons.wb_sunny_outlined,
              // This section title is localized for daily reminders.
              label: context.tr('daily_reminders'),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    // This empty state label is localized when there are no reminders.
                    context.tr('no_reminders'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.68),
                    ),
                  ),
                ),
              )
            else ...[
              const _SwipeDirectionLabels(),
              ...List.generate(
                items.length,
                    (index) {
                  final r = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MedsReminderTile(
                      data: r,
                      showSwipeHint: index == 0,
                      onToggle: (v) => vm.toggleEnabled(r.id, v),
                      onLongPress: () =>
                          _confirmDelete(context, r.id, r.title),
                      onMarkTaken: () => vm.markTaken(r.id),
                      onSkip: () => vm.skipDose(r.id),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () async {
          final result = await openAddBottomSheet(context);
          if (result != null && context.mounted) {
            await context.read<MedicalRemindersViewModel>().addReminder(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SwipeDirectionLabels extends StatelessWidget {
  const _SwipeDirectionLabels();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color labelColor =
    theme.colorScheme.onSurface.withOpacity(0.55);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: labelColor,
              ),
              const SizedBox(width: 4),
              Text(
                // This swipe helper label is localized for taken action.
                context.tr('taken'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: labelColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            // This swipe helper label is localized for swipe instruction.
            context.tr('swipe'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: labelColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                // This swipe helper label is localized for skip action.
                context.tr('skip'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: labelColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 12,
                color: labelColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}