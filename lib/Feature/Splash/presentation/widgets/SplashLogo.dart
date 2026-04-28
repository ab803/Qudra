import 'package:flutter/material.dart';
import 'package:qudra_0/core/widgets/adaptive_logo.dart';

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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Logo with scale + fade animation
        ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            // This block renders the correct splash logo asset for the active theme.
            child: const AdaptiveLogo(width: 160),
          ),
        ),
      ],
    );
  }
}
