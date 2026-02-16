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

  late SplashController controller;

  @override
  void initState() {
    super.initState();
    controller = SplashController(vsync: this, context: context);
    controller.init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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

            SplashLogo(
              scale: controller.logoScale,
              opacity: controller.logoOpacity,
            ),

            const SizedBox(height: 40),

            SplashTagline(
              slide: controller.textSlide,
              opacity: controller.textOpacity,
            ),

            const SizedBox(height: 50),

            SplashLoader(controller: controller.dotsController),
          ],
        ),
      ),
    );
  }
}
