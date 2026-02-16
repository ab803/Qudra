import 'package:flutter/material.dart';

class SplashAnimations {

  late Animation<double> logoScale;
  late Animation<double> logoOpacity;
  late Animation<Offset> textSlide;
  late Animation<double> textOpacity;

  SplashAnimations({
    required AnimationController logoController,
    required AnimationController textController,
  }) {

    logoScale = Tween<double>(begin: 0.6, end: 1)
        .animate(CurvedAnimation(
      parent: logoController,
      curve: Curves.easeOutBack,
    ));

    logoOpacity =
        Tween<double>(begin: 0, end: 1).animate(logoController);

    textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: textController,
      curve: Curves.easeOut,
    ));

    textOpacity =
        Tween<double>(begin: 0, end: 1).animate(textController);
  }
}
