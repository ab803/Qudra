import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class SosHoldButton extends StatefulWidget {
  const SosHoldButton({super.key});

  @override
  State<SosHoldButton> createState() => _SosHoldButtonState();
}

class _SosHoldButtonState extends State<SosHoldButton> {
  bool _holding = false;

  @override
  Widget build(BuildContext context) {
    const outer = 160.0;
    const inner = 120.0;

    return Center(
      child: GestureDetector(
        onLongPressStart: (_) => setState(() => _holding = true),
        onLongPressEnd: (_) => setState(() => _holding = false),
        child: Container(
          width: outer,
          height: outer,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _holding ? Appcolors.EmergancyColor : Colors.black,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_tethering, color: Colors.white, size: 34),
                SizedBox(height: 6),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}