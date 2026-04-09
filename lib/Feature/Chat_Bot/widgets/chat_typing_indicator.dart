import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 52, bottom: 6),
          child: Text(
            'Qudra AI',
            style: AppTextStyles.body.copyWith(
              color: Appcolors.secondaryColor,
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
              backgroundColor: Appcolors.cardTeal,
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              color: Appcolors.secondaryColor,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _animatedDot(int index) {
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
          color: Appcolors.textLight,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}