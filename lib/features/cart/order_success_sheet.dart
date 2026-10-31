import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order.dart';

/// Buyurtma muvaffaqiyatli — konfetti animatsiyasi bilan.
class OrderSuccessSheet extends StatefulWidget {
  const OrderSuccessSheet({super.key, required this.order});

  final Order order;

  @override
  State<OrderSuccessSheet> createState() => _OrderSuccessSheetState();
}

class _OrderSuccessSheetState extends State<OrderSuccessSheet>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(_c.value),
                  child: Center(
                    child: Transform.scale(
                      scale: Curves.elasticOut
                          .transform((_c.value * 1.6).clamp(0.0, 1.0)),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.sage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('order_placed'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${context.tr('order_no', {'id': widget.order.shortId})} · ${Fmt.money(widget.order.totalPrice)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.tr('order_placed_body'),
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.4,
                color: context.colors.onSurface.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed(Routes.orders);
              },
              child: Text(context.tr('view_orders')),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
              child: Text(context.tr('continue_shopping')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;

  static final _rand = math.Random(7);
  static final _pieces = List.generate(
    36,
    (i) => (
      angle: _rand.nextDouble() * 2 * math.pi,
      speed: 60 + _rand.nextDouble() * 110,
      size: 4 + _rand.nextDouble() * 5,
      color: const [
        AppColors.accent,
        AppColors.gold,
        AppColors.sage,
        Color(0xFF3D5A80),
        Color(0xFFB23A48),
      ][i % 5],
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint();
    for (final p in _pieces) {
      final d = p.speed * Curves.easeOut.transform(t);
      final gravity = 60 * t * t;
      final pos = center +
          Offset(math.cos(p.angle) * d, math.sin(p.angle) * d + gravity);
      paint.color = p.color.withOpacity((1 - t).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(t * 6 + p.angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
