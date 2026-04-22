import 'package:flutter/material.dart';

class EmergencySosCountdownCircle extends StatelessWidget {
  const EmergencySosCountdownCircle({
    super.key,
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  backgroundColor: colorScheme.error.withOpacity(0.14),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.error,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.error,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.error.withOpacity(0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: colorScheme.onError,
                  size: 34,
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    label,
                    key: ValueKey<String>(label),
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: colorScheme.onError.withOpacity(0.72),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}