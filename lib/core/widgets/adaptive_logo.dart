import 'package:flutter/material.dart';

// This widget switches between the light and dark logo assets based on the active theme.
class AdaptiveLogo extends StatelessWidget {
  const AdaptiveLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final double? width;
  final double? height;
  final BoxFit fit;

  static const String _lightModeLogoAsset =
      'assets/images/Qudra_logo_Light_mode.png';
  static const String _darkModeLogoAsset =
      'assets/images/Qudra_logo_Dark_mode.png';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Image.asset(
      isDark ? _darkModeLogoAsset : _lightModeLogoAsset,
      width: width,
      height: height,
      fit: fit,
    );
  }
}