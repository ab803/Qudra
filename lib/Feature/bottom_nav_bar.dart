import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/Styles/AppColors.dart';

class MainNavView extends StatefulWidget {
  final Widget child;

  const MainNavView({super.key, required this.child});

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  final NotchBottomBarController _controller =
  NotchBottomBarController(index: 0);

  final List<String> _routes = [
    '/home',
    '/institution',
    '/reminders',
    '/profile',
  ];

  void _onTap(int index) {
    _controller.index = index;
    context.go(_routes[index]); // 👈 THIS IS THE MAGIC
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, // 👈 show routed page here
      backgroundColor: Appcolors.backgroundColor,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Appcolors.backgroundColor,
        notchColor: Appcolors.primaryColor,
        showLabel: true,
        kIconSize: 24,
        kBottomRadius: 11,

        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_outlined),
            activeItem: Icon(Icons.home_outlined,color: Colors.white),
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.school_outlined),
            activeItem: Icon(Icons.school_outlined,color: Colors.white),
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.medical_services_outlined),
            activeItem: Icon(Icons.medical_services_outlined,color: Colors.white),
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person_outline),
            activeItem: Icon(Icons.person_outline,color: Colors.white),
          ),
        ],

        onTap: _onTap,
      ),
    );
  }
}
