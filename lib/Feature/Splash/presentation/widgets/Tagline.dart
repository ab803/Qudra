import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class SplashTagline extends StatelessWidget {

  final Animation<Offset> slide;
  final Animation<double> opacity;

  const SplashTagline({
    super.key,
    required this.slide,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: opacity,
        child: Text(
          "معاك علشان تكتشف قدراتك",
          style: AppTextStyles.slogan,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
