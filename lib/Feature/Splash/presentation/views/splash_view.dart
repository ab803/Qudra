import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
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

    // Initialize controller and pass vsync + context
    controller = SplashController(vsync: this, context: context);

    // Start animations
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
    return Scaffold(
      body: Container(
        width: double.infinity,

        // Background gradient (currently same color repeated)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Appcolors.backgroundColor,
              Appcolors.backgroundColor,
              Appcolors.backgroundColor,
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
