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

  // This method maps the current route to the correct bottom nav index.
  int _getSelectedIndex(String location) {
    if (location.startsWith('/institution')) {
      return 1;
    }
    if (location.startsWith('/community')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  // This method sends the user back to Home when pressing system back
  // from any bottom-nav tab other than Home.
  Future<bool> _handleBackPressed(BuildContext context) async {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(currentLocation);

    if (selectedIndex != 0) {
      context.go('/home');
      return false;
    }

    return true;
  }

  void _onTap(int index) {
    if (index < 0 || index >= _routes.length) return;

    final targetRoute = _routes[index];
    final currentLocation = GoRouterState.of(context).uri.toString();
    final currentIndex = _getSelectedIndex(currentLocation);

    // This avoids unnecessary navigation if the selected tab is already active.
    if (currentIndex == index) {
      return;
    }

    context.go(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(currentLocation);

    // This keeps the bottom bar indicator synced with the current route.
    if (_controller.index != selectedIndex) {
      _controller.index = selectedIndex;
    }

    return WillPopScope(
      onWillPop: () => _handleBackPressed(context),
      child: Scaffold(
        body: widget.child,
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
      ),
    );
  }
}