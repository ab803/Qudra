import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppIcons.dart';

class SplashLogo extends StatelessWidget {
  final Animation<double> scale;
  final Animation<double> opacity;

  const SplashLogo({
    super.key,
    required this.scale,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glowColor = theme.colorScheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.12 : 0.08,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background glow circle
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glowColor,
          ),
        ),

        // Logo with scale + fade animation
        ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: Image.asset(
              Appicons.logo,
              width: 160,
            ),
          ),
        ),
      ],
    );
  }
}