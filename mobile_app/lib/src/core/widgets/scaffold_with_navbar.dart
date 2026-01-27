import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.store),
            label: 'Shops',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.shoppingBag),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.receipt),
            label: 'Bills',
          ),
           NavigationDestination(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/shops')) return 1;
    if (location.startsWith('/orders')) return 2;
    if (location.startsWith('/bills')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/shops');
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        context.go('/bills');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
