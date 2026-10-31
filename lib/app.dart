import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/env.dart';
import 'core/l10n/app_localizations.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'data/local/local_storage.dart';
import 'data/repositories/store_repositories.dart';
import 'features/auth/auth_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/splash_screen.dart';
import 'state/auth_provider.dart';
import 'state/books_provider.dart';
import 'state/cart_provider.dart';
import 'state/library_provider.dart';
import 'state/orders_provider.dart';
import 'state/reviews_provider.dart';
import 'state/settings_provider.dart';
import 'state/wishlist_provider.dart';

/// Ilova bo'ylab ishlatiladigan servislar to'plami.
class AppServices {
  const AppServices({
    required this.storage,
    required this.books,
    required this.wishlist,
    required this.orders,
    required this.profile,
    required this.shelves,
    required this.reviews,
    required this.promo,
  });

  final LocalStorage storage;
  final BookRepository books;
  final WishlistRepository wishlist;
  final OrderRepository orders;
  final ProfileRepository profile;
  final ShelfRepository shelves;
  final ReviewRepository reviews;
  final PromoRepository promo;
}

class BookStoreApp extends StatelessWidget {
  const BookStoreApp({super.key, required this.auth, required this.services});

  final AuthProvider auth;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: services),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider(create: (_) => SettingsProvider(services.storage)),
        ChangeNotifierProvider(create: (_) => BooksProvider(services.books)),
        ChangeNotifierProvider(create: (_) => ReviewsProvider(services.reviews)),
        // Foydalanuvchiga bog'liq holatlar: akkaunt almashsa avtomatik
        // tozalanadi va yangidan yuklanadi.
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(services.storage, services.promo),
          update: (_, auth, cart) => cart!..bindUser(auth.isAuth ? auth.uid : null),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(services.wishlist),
          update: (_, auth, w) => w!..bindUser(auth.isAuth ? auth.uid : null),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(services.orders),
          update: (_, auth, o) => o!..bindUser(auth.isAuth ? auth.uid : null),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LibraryProvider>(
          create: (_) => LibraryProvider(
            shelfRepository: services.shelves,
            profileRepository: services.profile,
            storage: services.storage,
          ),
          update: (_, auth, l) => l!..bindUser(auth.isAuth ? auth.uid : null),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: Env.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: const _AppGate(),
          );
        },
      ),
    );
  }
}

/// Holatga qarab boshlang'ich ekranni tanlaydi.
class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((a) => a.status);
    final onboardingSeen =
        context.select<SettingsProvider, bool>((s) => s.onboardingSeen);

    final Widget child = switch (status) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.authenticated => const MainShell(),
      AuthStatus.unauthenticated =>
        onboardingSeen ? const AuthScreen() : const OnboardingScreen(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOut,
      child: KeyedSubtree(key: ValueKey(child.runtimeType), child: child),
    );
  }
}
