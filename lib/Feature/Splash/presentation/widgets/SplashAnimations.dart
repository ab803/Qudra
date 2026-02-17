import 'package:flutter/material.dart';

class SplashAnimations {

  // Logo animations
  late Animation<double> logoScale;
  late Animation<double> logoOpacity;

  // Text animations
  late Animation<Offset> textSlide;
  late Animation<double> textOpacity;

  SplashAnimations({
    required AnimationController logoController,
    required AnimationController textController,
  }) {

    // Logo scale animation (pop-in effect)
    logoScale = Tween<double>(begin: 0.6, end: 1)
        .animate(CurvedAnimation(
      parent: logoController,
      curve: Curves.easeOutBack,
    ));

    // Logo fade-in
    logoOpacity =
        Tween<double>(begin: 0, end: 1).animate(logoController);

    // Text slide from bottom
    textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: textController,
      curve: Curves.easeOut,
    ));

    // Text fade-in
    textOpacity =
        Tween<double>(begin: 0, end: 1).animate(textController);
  }
}
