import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      return '$missed missed • Next at $nextFormatted';
    }
    if (missed > 0) {
      return '$missed missed';
    }
    if (nextFormatted != null) {
      return 'Next at $nextFormatted';
    }
    if (vm.dueTodayCount == 0) {
      return 'No doses scheduled';
    }
    if (vm.takenTodayCount >= vm.dueTodayCount) {
      return 'All doses completed';
    }
    return 'No upcoming doses';
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
        title: const Text('Delete Reminder?'),
        content: Text('Delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
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
              caption: 'Doses completed',
              footerText: _buildProgressFooter(context, vm),
              missedCount: vm.missedTodayCount,
            ),
            if (vm.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                vm.errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 18),
            const MedsSectionTitle(
              icon: Icons.wb_sunny_outlined,
              label: 'Daily Reminders',
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    'No reminders yet. Tap + to add one.',
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
                'Taken',
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
            'Swipe',
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
                'Skip',
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
