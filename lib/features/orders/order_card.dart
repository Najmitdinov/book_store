import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order.dart';

Color statusColor(OrderStatus s) => switch (s) {
      OrderStatus.newOrder => const Color(0xFF3D5A80),
      OrderStatus.processing => AppColors.gold,
      OrderStatus.shipped => AppColors.accent,
      OrderStatus.delivered => AppColors.sage,
      OrderStatus.cancelled => AppColors.danger,
    };

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        context.tr(status.labelKey),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.initiallyExpanded = false,
    this.trailing,
  });

  final Order order;
  final bool initiallyExpanded;

  /// Admin ekrani uchun qo'shimcha boshqaruv.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: context.theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('order_no', {'id': order.shortId}),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              StatusPill(status: order.status),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Text(
                  Fmt.dateTime(order.date, context.langCode),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurface.withOpacity(0.55),
                  ),
                ),
                const Spacer(),
                Text(
                  Fmt.money(order.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          children: [
            _Timeline(status: order.status),
            const SizedBox(height: 16),
            for (final p in order.products)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 36,
                        height: 52,
                        child: p.imgUrl.isEmpty
                            ? Container(color: AppColors.accentSoft)
                            : CachedNetworkImage(
                                imageUrl: p.imgUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    Container(color: AppColors.accentSoft),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${p.quantity} × ${Fmt.money(p.price)}',
                      style: TextStyle(
                        color: context.colors.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            if (order.discountAmount > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${context.tr('discount')}: −${Fmt.money(order.discountAmount)}'
                  '${order.promoCode != null ? ' (${order.promoCode})' : ''}',
                  style: const TextStyle(
                    color: AppColors.sage,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (trailing != null) ...[const SizedBox(height: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Buyurtma bosqichlari vaqt chizig'i.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Row(
        children: [
          const Icon(Icons.cancel_rounded, color: AppColors.danger),
          const SizedBox(width: 8),
          Text(
            context.tr(status.labelKey),
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    final current = OrderStatus.flow.indexOf(status);
    return Row(
      children: [
        for (var i = 0; i < OrderStatus.flow.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= current
                        ? statusColor(OrderStatus.flow[i])
                        : context.colors.onSurface.withOpacity(0.1),
                  ),
                  child: i <= current
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(OrderStatus.flow[i].labelKey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: i == current ? FontWeight.w800 : null,
                    color: i <= current
                        ? null
                        : context.colors.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
