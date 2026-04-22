import 'package:flutter/material.dart';

class EmergencySosButton extends StatefulWidget {
  const EmergencySosButton({
    super.key,
    required this.onLongPress,
  });

  final VoidCallback onLongPress;

  @override
  State<EmergencySosButton> createState() => _EmergencySosButtonState();
}

class _EmergencySosButtonState extends State<EmergencySosButton>
    with SingleTickerProviderStateMixin {
  bool _isPressing = false;
  late final AnimationController _pulseController;

  void _setPressing(bool value) {
    if (_isPressing == value) return;
    setState(() {
      _isPressing = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildPulseRing({
    required double delay,
    required double baseSize,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        if (_isPressing) {
          return const SizedBox.shrink();
        }

        final rawValue = (_pulseController.value + delay) % 1.0;

        // يبدأ من 0 ويكبر تدريجيًا
        final scale = 1.0 + (rawValue * 0.55);

        // الشفافية تقل كل ما الحلقة تكبر
        final opacity = (1.0 - rawValue) * 0.22;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: baseSize,
              height: baseSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const Color idleInnerColor = Color(0xFF111827);

    final Color innerColor =
    _isPressing ? colorScheme.error : idleInnerColor;

    final Color shadowColor = _isPressing
        ? colorScheme.error.withOpacity(0.28)
        : theme.shadowColor.withOpacity(
      theme.brightness == Brightness.dark ? 0.12 : 0.08,
    );

    final Color innerForegroundColor =
    _isPressing ? colorScheme.onError : Colors.white;

    final Color pulseColor = colorScheme.error.withOpacity(
      theme.brightness == Brightness.dark ? 0.55 : 0.45,
    );

    return Column(
      children: [
        SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildPulseRing(
                delay: 0.0,
                baseSize: 170,
                color: pulseColor,
              ),
              _buildPulseRing(
                delay: 0.5,
                baseSize: 170,
                color: pulseColor,
              ),
              GestureDetector(
                onLongPressStart: (_) => _setPressing(true),
                onLongPressEnd: (_) => _setPressing(false),
                onLongPressCancel: () => _setPressing(false),
                onLongPress: widget.onLongPress,
                child: AnimatedScale(
                  scale: _isPressing ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.cardColor,
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: _isPressing ? 24 : 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: innerColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sensors_rounded,
                            color: innerForegroundColor,
                            size: 34,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SOS',
                            style: TextStyle(
                              color: innerForegroundColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اضغط مطولًا للتفعيل',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.68),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}