import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChatTypingIndicator extends StatefulWidget {
  final String time;

  const ChatTypingIndicator({
    super.key,
    required this.time,
  });

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 52, bottom: 6),
          child: Text(
            'Qudra AI',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.65),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withOpacity(
                theme.brightness == Brightness.dark ? 0.20 : 0.12,
              ),
              child: Text(
                'AI',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(
                      theme.brightness == Brightness.dark ? 0.08 : 0.04,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _animatedDot(0),
                  const SizedBox(width: 4),
                  _animatedDot(1),
                  const SizedBox(width: 4),
                  _animatedDot(2),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 52, top: 6),
          child: Text(
            widget.time,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _animatedDot(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // فرق بسيط بين كل نقطة والتانية
        final phaseShift = index * 0.8;

        // قيمة متغيرة بين 0 و 1
        final wave = math.sin((_controller.value * 2 * math.pi) - phaseShift);
        final progress = wave.abs();

        final opacity = 0.35 + (progress * 0.65);
        final translateY = -4.0 * progress;
        final scale = 0.85 + (progress * 0.25);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.45),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}