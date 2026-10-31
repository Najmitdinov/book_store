import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../network/app_exception.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Narx: chegirma bo'lsa eski narx chizilgan holda yonida turadi.
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.originalPrice,
    this.fontSize = 16,
  });

  final double price;
  final double? originalPrice;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final showOld = originalPrice != null && originalPrice! > price + 0.001;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 6,
      children: [
        Text(
          Fmt.money(price),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: showOld ? AppColors.accent : context.colors.onSurface,
          ),
        ),
        if (showOld)
          Text(
            Fmt.money(originalPrice!),
            style: TextStyle(
              fontSize: fontSize * 0.75,
              color: context.colors.onSurface.withOpacity(0.45),
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.onChanged,
  });

  final double rating;
  final double size;

  /// Berilsa — yulduzlar bosiladigan bo'ladi.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final value = i + 1;
        final icon = rating >= value
            ? Icons.star_rounded
            : rating >= value - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        final star = Icon(icon, size: size, color: AppColors.gold);
        if (onChanged == null) return star;
        return InkResponse(
          radius: size,
          onTap: () => onChanged!(value.toDouble()),
          child: Padding(padding: const EdgeInsets.all(2), child: star),
        );
      }),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 12, 12),
  });

  final String title;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              child: Text(context.tr('see_all')),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 110,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.code, required this.onRetry});

  final String? code;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: code == 'err_network' ? '📡' : '😕',
      title: context.tr('error_title'),
      subtitle: context.tr(code ?? 'err_unknown'),
      action: SizedBox(
        width: 200,
        child: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(context.tr('retry')),
        ),
      ),
    );
  }
}

/// Yuklanish skeleti — miltillovchi kulrang blok.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height, this.radius = 12});

  final double? width;
  final double? height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.onSurface;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base.withOpacity(0.05 + 0.06 * _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.colorIndex = 0,
    this.size = 44,
  });

  final String name;
  final int colorIndex;
  final double size;

  static const palettes = [
    [Color(0xFFD9653B), Color(0xFFE2A93B)],
    [Color(0xFF5E8C6A), Color(0xFF9CC5A1)],
    [Color(0xFF3D5A80), Color(0xFF98C1D9)],
    [Color(0xFF7B4B94), Color(0xFFC09BD8)],
    [Color(0xFFB23A48), Color(0xFFF2A1A1)],
    [Color(0xFF1F1B16), Color(0xFF6B635A)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = palettes[colorIndex.abs() % palettes.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Text(
        Fmt.initials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

// ---- Xabarlar ----

void showSnack(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  bool error = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? context.colors.error : null,
      duration: const Duration(seconds: 3),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
}

void showError(BuildContext context, Object error) {
  final code = error is AppException ? error.code : 'err_unknown';
  showSnack(context, context.tr(code), error: true);
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.tr('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 44),
            backgroundColor: destructive ? ctx.colors.error : null,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel ?? ctx.tr('ok')),
        ),
      ],
    ),
  );
  return result ?? false;
}
