import 'package:flutter/material.dart';

// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../models/reminder_model.dart';

// This model carries UI-ready data for one care plan reminder tile.
class ReminderViewData {
  final String id;
  final String title;
  final String subtitle;
  final String? timeText;
  final bool isEnabled;
  final String? statusLabel;

  // This field stores the localized care plan type label shown in the tile badge.
  final String? typeLabel;

  // This field stores the care plan type icon shown in the tile badge.
  final IconData? typeIcon;

  // This field stores the raw care plan type for color styling.
  final CarePlanType type;

  ReminderViewData({
    required this.id,
    required this.title,
    required this.subtitle,
    this.timeText,
    this.isEnabled = false,
    this.statusLabel,
    this.typeLabel,
    this.typeIcon,
    this.type = CarePlanType.medication,
  });
}

class MedsReminderTile extends StatefulWidget {
  final ReminderViewData data;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onSkip;
  final bool showSwipeHint;

  const MedsReminderTile({
    super.key,
    required this.data,
    this.onToggle,
    this.onTap,
    this.onLongPress,
    this.onMarkTaken,
    this.onSkip,
    this.showSwipeHint = false,
  });

  @override
  State<MedsReminderTile> createState() => _MedsReminderTileState();
}

class _MedsReminderTileState extends State<MedsReminderTile>
    with SingleTickerProviderStateMixin {
  bool _isPlayingHint = false;
  late final AnimationController _controller;
  late final Animation<double> _slideX;

  // This method plays a short horizontal motion to teach the user the swipe action.
  Future<void> _playSwipeHint() async {
    if (_isPlayingHint) return;
    _isPlayingHint = true;

    for (var i = 0; i < 2; i++) {
      if (!mounted) break;

      await _controller.forward(from: 0);

      if (!mounted) break;

      await Future.delayed(const Duration(milliseconds: 180));
    }

    _isPlayingHint = false;
  }

  @override
  void initState() {
    super.initState();

    // This controller drives the swipe hint animation.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // This animation moves the tile right, then left, then back to center.
    _slideX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 12.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 12.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    // This block starts the swipe hint only for the first visible item.
    if (widget.showSwipeHint) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await Future.delayed(const Duration(milliseconds: 350));

        if (!mounted) return;

        await _playSwipeHint();
      });
    }
  }

  @override
  void didUpdateWidget(covariant MedsReminderTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // This block replays the hint if this tile becomes the first visible item after filtering.
    if (!oldWidget.showSwipeHint && widget.showSwipeHint) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await Future.delayed(const Duration(milliseconds: 350));

        if (!mounted) return;

        await _playSwipeHint();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // This helper maps each care plan type to a stable accent color.
  Color _typeAccentColor(BuildContext context, CarePlanType type) {
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

  // This helper returns the status background color.
  static Color _statusBgColor(String label) {
    switch (label) {
      case 'status_taken_today':
        return Colors.green.withOpacity(0.12);
      case 'status_skipped_today':
        return Colors.orange.withOpacity(0.14);
      case 'status_missed':
        return Colors.red.withOpacity(0.12);
      default:
        return Colors.grey.withOpacity(0.12);
    }
  }

  // This helper returns the status text color.
  static Color _statusTextColor(String label) {
    switch (label) {
      case 'status_taken_today':
        return Colors.green.shade800;
      case 'status_skipped_today':
        return Colors.orange.shade800;
      case 'status_missed':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dismissDirection =
    (widget.onMarkTaken != null || widget.onSkip != null)
        ? DismissDirection.horizontal
        : DismissDirection.none;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideX.value, 0),
          child: child,
        );
      },
      child: Dismissible(
        key: ValueKey('reminder_${widget.data.id}'),
        direction: dismissDirection,

        // This background appears when swiping right to mark the item as completed.
        background: _SwipeBackground(
          color: Colors.green,
          icon: Icons.check_rounded,
          label: context.tr('mark_as_taken'),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 18),
        ),

        // This background appears when swiping left to skip the item.
        secondaryBackground: _SwipeBackground(
          color: Colors.orange,
          icon: Icons.skip_next_rounded,
          label: context.tr('skip'),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 18),
        ),

        // This block handles swipe actions without removing the tile from the list.
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            widget.onMarkTaken?.call();
          } else if (direction == DismissDirection.endToStart) {
            widget.onSkip?.call();
          }

          return false;
        },

        child: _CarePlanTileSurface(
          data: widget.data,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onToggle: widget.onToggle,
          typeAccentColor: _typeAccentColor(context, widget.data.type),
        ),
      ),
    );
  }
}

// This widget renders the main visual surface for one care plan item.
class _CarePlanTileSurface extends StatelessWidget {
  final ReminderViewData data;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onToggle;
  final Color typeAccentColor;

  const _CarePlanTileSurface({
    required this.data,
    required this.onTap,
    required this.onLongPress,
    required this.onToggle,
    required this.typeAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(
                theme.brightness == Brightness.dark ? 0.08 : 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // This block shows the type icon for medication, feeding, rehab, or learning.
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: typeAccentColor.withOpacity(
                  theme.brightness == Brightness.dark ? 0.18 : 0.10,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                data.typeIcon ?? Icons.event_note_outlined,
                color: typeAccentColor,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This badge identifies the care plan category of the item.
                  if (data.typeLabel != null &&
                      data.typeLabel!.trim().isNotEmpty) ...[
                    _TypeBadge(
                      label: data.typeLabel!,
                      icon: data.typeIcon ?? Icons.event_note_outlined,
                      color: typeAccentColor,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // This text shows the care plan item title.
                  Text(
                    data.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // This row shows notes/guidance and scheduled time.
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12.5,
                            height: 1.15,
                            color: colorScheme.onSurface.withOpacity(0.68),
                          ),
                        ),
                      ),
                      if (data.timeText != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurface.withOpacity(0.54),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data.timeText!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12.5,
                            height: 1.1,
                            color: colorScheme.onSurface.withOpacity(0.68),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // This block shows the daily status badge when available.
                  if (data.statusLabel != null) ...[
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: MedsReminderTileStateHelpers.statusBgColor(
                          data.statusLabel!,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.tr(data.statusLabel!),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: MedsReminderTileStateHelpers.statusTextColor(
                            data.statusLabel!,
                          ),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // This switch enables or disables the care plan reminder.
            Switch.adaptive(
              value: data.isEnabled,
              onChanged: onToggle,
              activeColor: colorScheme.onPrimary,
              activeTrackColor: colorScheme.primary,
              inactiveThumbColor: theme.cardColor,
              inactiveTrackColor: colorScheme.onSurface.withOpacity(0.18),
            ),
          ],
        ),
      ),
    );
  }
}

// This helper class exposes status colors to child stateless widgets.
class MedsReminderTileStateHelpers {
  // This helper returns the status background color for the current daily state.
  static Color statusBgColor(String label) {
    switch (label) {
      case 'status_taken_today':
        return Colors.green.withOpacity(0.12);
      case 'status_skipped_today':
        return Colors.orange.withOpacity(0.14);
      case 'status_missed':
        return Colors.red.withOpacity(0.12);
      default:
        return Colors.grey.withOpacity(0.12);
    }
  }

  // This helper returns the status text color for the current daily state.
  static Color statusTextColor(String label) {
    switch (label) {
      case 'status_taken_today':
        return Colors.green.shade800;
      case 'status_skipped_today':
        return Colors.orange.shade800;
      case 'status_missed':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}

// This widget renders a compact badge for the care plan item type.
class _TypeBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TypeBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(
          theme.brightness == Brightness.dark ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;
  final EdgeInsets padding;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]
            : [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}