import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../state/books_provider.dart';
import '../../state/cart_provider.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';

/// Asosiy navigatsiya. [IndexedStack] tablar holatini (scroll, qidiruv)
/// saqlab qoladi.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().load();
    });
  }

  void goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ExploreScreen(),
          LibraryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: goTo,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: AppColors.accent),
            label: context.tr('nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon:
                const Icon(Icons.manage_search_rounded, color: AppColors.accent),
            label: context.tr('nav_explore'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon:
                const Icon(Icons.auto_stories_rounded, color: AppColors.accent),
            label: context.tr('nav_library'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon:
                const Icon(Icons.person_rounded, color: AppColors.accent),
            label: context.tr('nav_profile'),
          ),
        ],
      ),
    );
  }
}

/// Savat ikonkasi + jonli hisoblagich (barcha ekranlarda bir xil).
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((c) => c.count);
    return IconButton(
      onPressed: () => Navigator.of(context).pushNamed(Routes.cart),
      icon: Badge(
        isLabelVisible: count > 0,
        backgroundColor: AppColors.accent,
        label: Text('$count'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
