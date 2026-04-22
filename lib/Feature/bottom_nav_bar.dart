import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    '/community',
    '/profile',
  ];

  void _onTap(int index) {
    _controller.index = index;
    context.go(_routes[index]); // 👈 THIS IS THE MAGIC
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: widget.child, // 👈 show routed page here
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: theme.cardColor,
        notchColor: theme.colorScheme.primary,
        showLabel: true,
        kIconSize: 24,
        kBottomRadius: 11,
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(
              Icons.home_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
            activeItem: Icon(
              Icons.home_outlined,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Symbols.corporate_fare,
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
            activeItem: Icon(
              Symbols.corporate_fare,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Symbols.groups,
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
            activeItem: Icon(
              Symbols.groups,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.person_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
            activeItem: Icon(
              Icons.person_outline,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
        onTap: _onTap,
      ),
    );
  }
}