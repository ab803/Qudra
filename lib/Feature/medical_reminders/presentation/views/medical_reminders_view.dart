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

  // This helper converts a stored HH:mm time into the user's localized time format.
  String _formatTimeForUi(BuildContext context, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;

    final tod = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    return MaterialLocalizations.of(context).formatTimeOfDay(tod);
  }

  // This helper maps each care plan type to a visual icon for reminder tiles.
  IconData _iconForCarePlanType(CarePlanType type) {
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

  // This helper maps each care plan type to a stable localization key.
  String _labelKeyForCarePlanType(CarePlanType type) {
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

  // This helper maps a reminder model into UI-friendly tile data.
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

      // This block passes the care plan type data to the tile UI.
      typeLabel: context.tr(_labelKeyForCarePlanType(m.type)),
      typeIcon: _iconForCarePlanType(m.type),
      type: m.type,
    );
  }

  // This helper builds the progress footer for today's care plan tasks.
  String _buildProgressFooter(
      BuildContext context,
      MedicalRemindersViewModel vm,
      ) {
    final int missed = vm.missedTodayCount;
    final String? nextRaw = vm.nextReminderTime;
    final String? nextFormatted =
    nextRaw == null ? null : _formatTimeForUi(context, nextRaw);

    if (missed > 0 && nextFormatted != null) {
      // This footer combines missed tasks with the next scheduled care plan item.
      return '$missed ${context.tr('missed')} • ${context.tr('next_at')} $nextFormatted';
    }

    if (missed > 0) {
      // This footer shows missed tasks only.
      return '$missed ${context.tr('missed')}';
    }

    if (nextFormatted != null) {
      // This footer shows the next scheduled care plan item.
      return '${context.tr('next_at')} $nextFormatted';
    }

    if (vm.dueTodayCount == 0) {
      // This footer label is localized when no tasks are scheduled.
      return context.tr('no_tasks_scheduled');
    }

    if (vm.takenTodayCount >= vm.dueTodayCount) {
      // This footer label is localized when all care plan tasks are completed.
      return context.tr('all_tasks_completed');
    }

    // This footer label is localized when there are no upcoming tasks.
    return context.tr('no_upcoming_tasks');
  }

  // This helper confirms deleting a care plan item.
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
        // This dialog title is localized for deleting a care plan item.
        title: Text(context.tr('delete_care_plan_item')),

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

    // This block uses the filtered list instead of all reminders.
    final items = vm.visibleReminders.map((m) => _toViewData(context, vm, m)).toList();

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
            // This header now presents the feature as Care Plans instead of medication-only reminders.
            const MedsHeader(),
            const SizedBox(height: 14),

            // This card summarizes today's completion across medication, feeding, rehab, and learning tasks.
            MedsProgressCard(
              taken: vm.takenTodayCount,
              total: vm.dueTodayCount,
              caption: context.tr('tasks_completed'),
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

            // This disclaimer keeps feeding guidance safe and non-medical.
            _CarePlanGuidanceNotice(),

            const SizedBox(height: 18),

            // This section title explains that the list contains all daily care plan items.
            MedsSectionTitle(
              icon: Icons.event_available_outlined,
              label: context.tr('daily_care_plan_items'),
            ),

            const SizedBox(height: 12),

            // This filter bar lets the user switch between care plan item types.
            _CarePlanFilterChips(
              selectedFilter: vm.selectedFilter,
              filters: vm.availableFilters,
              onChanged: vm.setSelectedFilter,
            ),

            const SizedBox(height: 14),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    // This empty state changes depending on the selected care plan filter.
                    vm.selectedFilter == CarePlanFilter.all
                        ? context.tr('no_care_plan_items')
                        : context.tr('no_items_in_selected_plan'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.68),
                      height: 1.5,
                    ),
                  ),
                ),
              )
            else ...[
              const _SwipeDirectionLabels(),

              // This list renders all filtered care plan items.
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

      // This button opens the upgraded bottom sheet that supports all Care Plan types.
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

// This widget shows a safe guidance notice for care plan items.
class _CarePlanGuidanceNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(
          theme.brightness == Brightness.dark ? 0.14 : 0.08,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // This notice clarifies that feeding and rehab guidance are general support.
              context.tr('care_plans_general_disclaimer'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This widget renders filter chips for all care plan categories.
class _CarePlanFilterChips extends StatelessWidget {
  final CarePlanFilter selectedFilter;
  final List<CarePlanFilter> filters;
  final ValueChanged<CarePlanFilter> onChanged;

  const _CarePlanFilterChips({
    required this.selectedFilter,
    required this.filters,
    required this.onChanged,
  });

  // This helper maps each filter to a visual icon.
  IconData _iconForFilter(CarePlanFilter filter) {
    switch (filter) {
      case CarePlanFilter.all:
        return Icons.dashboard_customize_outlined;
      case CarePlanFilter.medication:
        return Icons.medication_outlined;
      case CarePlanFilter.feeding:
        return Icons.restaurant_outlined;
      case CarePlanFilter.rehab:
        return Icons.fitness_center_outlined;
      case CarePlanFilter.learning:
        return Icons.school_outlined;
    }
  }

  // This helper maps each filter to a visual accent color.
  Color _accentForFilter(CarePlanFilter filter, BuildContext context) {
    switch (filter) {
      case CarePlanFilter.all:
        return Theme.of(context).colorScheme.primary;
      case CarePlanFilter.medication:
        return const Color(0xFF22C55E);
      case CarePlanFilter.feeding:
        return const Color(0xFFF97316);
      case CarePlanFilter.rehab:
        return const Color(0xFF3B82F6);
      case CarePlanFilter.learning:
        return const Color(0xFFA855F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _CarePlanFilterChip(
              label: context.tr(filter.labelKey),
              icon: _iconForFilter(filter),
              accentColor: _accentForFilter(filter, context),
              isSelected: isSelected,
              onTap: () => onChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// This widget renders one filter chip for a care plan category.
class _CarePlanFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CarePlanFilterChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                icon,
                size: 18,
                color: isSelected
                    ? accentColor
                    : colorScheme.onSurface.withOpacity(0.68),
              ),
              const SizedBox(width: 7),
              Text(
                label,
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

class _SwipeDirectionLabels extends StatelessWidget {
  const _SwipeDirectionLabels();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color labelColor = theme.colorScheme.onSurface.withOpacity(0.55);

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
                // This swipe helper label is localized for completed action.
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