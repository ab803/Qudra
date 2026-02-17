import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'SplashAnimations.dart';

class SplashController {

  // Required for animation tick
  final TickerProvider vsync;

  // Needed for navigation
  final BuildContext context;

  // Animation controllers
  late AnimationController logoController;
  late AnimationController textController;
  late AnimationController dotsController;

  // Animation definitions
  late SplashAnimations animations;

  SplashController({required this.vsync, required this.context});

  void init() {
    // Logo animation duration
    logoController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    // Text animation duration
    textController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );

    // Loading dots animation (looping)
    dotsController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Initialize animation objects
    animations = SplashAnimations(
      logoController: logoController,
      textController: textController,
    );

    startAnimation();
    navigateNext();
  }

  // Start animations sequentially
  void startAnimation() {
    logoController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      textController.forward();
    });
  }

  // Navigate to home screen after delay
  void navigateNext() {
    Timer(const Duration(seconds: 4), () {
      if (context.mounted) {
        context.go('/home');
      }
    });
  }

  // Expose animations
  Animation<double> get logoScale => animations.logoScale;
  Animation<double> get logoOpacity => animations.logoOpacity;
  Animation<Offset> get textSlide => animations.textSlide;
  Animation<double> get textOpacity => animations.textOpacity;

  // Dispose resources
  void dispose() {
    logoController.dispose();
    textController.dispose();
    dotsController.dispose();
  }
}
