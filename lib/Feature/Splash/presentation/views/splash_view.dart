import 'package:flutter/material.dart';
import '../widgets/Loader.dart';
import '../widgets/SplashLogo.dart';
import '../widgets/Tagline.dart';
import '../widgets/splashController.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  // Controller that manages animations and navigation
  late SplashController controller;

  @override
  void initState() {
    super.initState();
    controller = SplashController(vsync: this, context: context);
    controller.init();
  }

  @override
  void dispose() {
    // Always dispose animation controllers to prevent memory leaks
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        // Background gradient (currently same color repeated)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.scaffoldBackgroundColor,
              theme.cardColor,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            SplashLogo(
              scale: controller.logoScale,
              opacity: controller.logoOpacity,
            ),
            const SizedBox(height: 40),
            // Animated tagline text
            SplashTagline(
              slide: controller.textSlide,
              opacity: controller.textOpacity,
            ),
            const SizedBox(height: 50),
            // Animated loading dots
            SplashLoader(controller: controller.dotsController),
          ],
        ),
      ),
    );
  }
}