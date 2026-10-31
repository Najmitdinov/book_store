import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Qog'oz va siyoh" dizayn tizimi: iliq qog'oz foni, chuqur siyoh rangi
/// va terrakota urg'usi. Qorong'i rejimda — tungi kutubxona kayfiyati.
class AppColors {
  AppColors._();

  static const ink = Color(0xFF1F1B16);
  static const paper = Color(0xFFFAF6EF);
  static const paperDim = Color(0xFFF1EADF);
  static const accent = Color(0xFFD9653B); // terrakota
  static const accentSoft = Color(0xFFF6D9C8);
  static const sage = Color(0xFF5E8C6A);
  static const gold = Color(0xFFE2A93B);
  static const danger = Color(0xFFC0392B);

  static const nightBg = Color(0xFF14161C);
  static const nightSurface = Color(0xFF1E2129);
  static const nightCard = Color(0xFF262A34);
}

class AppTheme {
  AppTheme._();

  static const _font = 'Maat_Rounded';
  static const radius = 18.0;

  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.ink,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          tertiary: AppColors.sage,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
          surfaceContainerHighest: AppColors.paperDim,
          error: AppColors.danger,
        ),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFF4EDE2),
          onPrimary: AppColors.ink,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          tertiary: const Color(0xFF8CC09A),
          surface: AppColors.nightBg,
          onSurface: const Color(0xFFF4EDE2),
          surfaceContainerHighest: AppColors.nightCard,
          error: const Color(0xFFE57368),
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _font,
      scaffoldBackgroundColor: scheme.surface,
    );

    final fieldFill = isDark ? AppColors.nightSurface : Colors.white;

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: scheme.onSurface.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(
            fontFamily: _font,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: scheme.onSurface.withOpacity(0.15)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        side: BorderSide(color: scheme.onSurface.withOpacity(0.1)),
        labelStyle: TextStyle(fontFamily: _font, color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isDark ? AppColors.nightSurface : Colors.white,
        indicatorColor: AppColors.accent.withOpacity(0.16),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: _font, fontSize: 12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerColor: scheme.onSurface.withOpacity(0.08),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Karta foni (yorug' rejimda oq, qorong'ida to'q kulrang).
  Color get cardColor => isDark ? AppColors.nightCard : Colors.white;
}
