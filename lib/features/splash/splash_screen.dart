import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    // Animatsiya ko'rinib ulgurishi uchun kichik pauza bilan sessiyani tiklaymiz.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<AuthProvider>().restore(),
        Future.delayed(const Duration(milliseconds: 900)),
      ]);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return Scaffold(
      backgroundColor: context.isDark ? AppColors.nightBg : AppColors.ink,
      body: Center(
        child: FadeTransition(
          opacity: _c,
          child: ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(curve),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Logo(size: 96),
                SizedBox(height: 20),
                Text(
                  'Kitobxon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.gold],
        ),
      ),
      child: Icon(
        Icons.auto_stories_rounded,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}
