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

class _EmergencySosButtonState extends State<EmergencySosButton> {
  bool _isPressing = false;

  void _setPressing(bool value) {
    if (_isPressing == value) return;
    setState(() {
      _isPressing = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color innerColor =
    _isPressing ? const Color(0xFFEF4444) : const Color(0xFF111827);

    final Color shadowColor =
    _isPressing ? const Color(0xFFEF4444).withOpacity(0.28) : Colors.black.withOpacity(0.08);

    return Column(
      children: [
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
                color: Colors.white,
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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sensors_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
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
        const SizedBox(height: 12),
        const Text(
          'اضغط مطولًا للتفعيل',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}