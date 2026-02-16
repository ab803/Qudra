import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'SplashAnimations.dart';

class SplashController {
  final TickerProvider vsync;
  final BuildContext context;

  late AnimationController logoController;
  late AnimationController textController;
  late AnimationController dotsController;

  late SplashAnimations animations;

  SplashController({required this.vsync, required this.context});

  void init() {
    logoController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    textController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );

    dotsController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    animations = SplashAnimations(
      logoController: logoController,
      textController: textController,
    );

    startAnimation();
    navigateNext();
  }

  void startAnimation() {
    logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      textController.forward();
    });
  }

  void navigateNext() {
    Timer(const Duration(seconds: 4), () {
      if (context.mounted) {
        context.go('/home');
      }
    });
  }

  Animation<double> get logoScale => animations.logoScale;
  Animation<double> get logoOpacity => animations.logoOpacity;
  Animation<Offset> get textSlide => animations.textSlide;
  Animation<double> get textOpacity => animations.textOpacity;

  void dispose() {
    logoController.dispose();
    textController.dispose();
    dotsController.dispose();
  }
}
