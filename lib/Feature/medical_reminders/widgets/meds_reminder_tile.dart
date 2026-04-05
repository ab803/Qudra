import 'package:flutter/material.dart';

class ReminderViewData {
  final String id;
  final String title;
  final String subtitle;
  final String? timeText;
  final bool isEnabled;
  final String? statusLabel;

  ReminderViewData({
    required this.id,
    required this.title,
    required this.subtitle,
    this.timeText,
    this.isEnabled = false,
    this.statusLabel,
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
  late final AnimationController _controller;
  late final Animation<double> _slideX;

  Future<void> _playSwipeHint() async {
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;

      _controller.reset();
      await _controller.forward();

      if (!mounted) return;

      // pause صغيرة بين كل مرة والتانية
      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 180));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

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

  @override
  Widget build(BuildContext context) {
    final dismissDirection = (widget.onMarkTaken != null || widget.onSkip != null)
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
        background: _SwipeBackground(
          color: Colors.green,
          icon: Icons.check_rounded,
          label: 'Mark as taken',
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 18),
        ),
        secondaryBackground: _SwipeBackground(
          color: Colors.orange,
          icon: Icons.skip_next_rounded,
          label: 'Skip',
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 18),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            widget.onMarkTaken?.call();
          } else if (direction == DismissDirection.endToStart) {
            widget.onSkip?.call();
          }
          return false;
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.data.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.1,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          if (widget.data.timeText != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              widget.data.timeText!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.1,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.data.statusLabel != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBgColor(widget.data.statusLabel!),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.data.statusLabel!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _statusTextColor(widget.data.statusLabel!),
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Switch.adaptive(
                  value: widget.data.isEnabled,
                  onChanged: widget.onToggle,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.black87,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.black12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _statusBgColor(String label) {
    switch (label) {
      case 'Taken today':
        return Colors.green.withOpacity(0.12);
      case 'Skipped today':
        return Colors.orange.withOpacity(0.14);
      case 'Missed':
        return Colors.red.withOpacity(0.12);
      default:
        return Colors.grey.withOpacity(0.12);
    }
  }

  static Color _statusTextColor(String label) {
    switch (label) {
      case 'Taken today':
        return Colors.green.shade800;
      case 'Skipped today':
        return Colors.orange.shade800;
      case 'Missed':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
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
    final bool isLeft = alignment == Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
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
