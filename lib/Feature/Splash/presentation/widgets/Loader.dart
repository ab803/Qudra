import 'package:flutter/material.dart';

class SplashLoader extends StatelessWidget {

  final AnimationController controller;

  const SplashLoader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            double scale = 1 +
                (controller.value *
                    (index == 1 ? 0.6 : 0.3));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Transform.scale(
                scale: scale,
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.black,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
