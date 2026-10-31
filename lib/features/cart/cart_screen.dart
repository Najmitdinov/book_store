import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../data/models/cart_item.dart';
import '../../state/cart_provider.dart';
import '../../state/orders_provider.dart';
import 'cart_widgets.dart';
import 'order_success_sheet.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _placing = false;

  Future<void> _clear(CartProvider cart) async {
    final ok = await confirmDialog(
      context,
      title: context.tr('clear_cart_confirm'),
      confirmLabel: context.tr('clear'),
      destructive: true,
    );
    if (ok) cart.clear();
  }

  void _remove(CartProvider cart, CartItem item) {
    final removed = cart.remove(item.id);
    if (removed == null) return;
    showSnack(
      context,
      '«${item.title}» — ${context.tr('delete').toLowerCase()}',
      actionLabel: context.tr('cancel'),
      onAction: () => cart.restore(removed),
    );
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    setState(() => _placing = true);
    try {
      final order = await orders.place(
        items: cart.items,
        total: cart.total,
        discountAmount: cart.bookSavings + cart.promoDiscount,
        promoCode: cart.promoCode,
      );
      cart.clear();
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => OrderSuccessSheet(order: order),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('cart_title')),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _clear(cart),
              child: Text(context.tr('clear')),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              emoji: '🛍️',
              title: context.tr('cart_empty'),
              subtitle: context.tr('cart_empty_hint'),
              action: SizedBox(
                width: 240,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(Routes.orders),
                  child: Text(context.tr('my_orders')),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                for (final item in cart.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _remove(cart, item),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      child: CartItemTile(
                        item: item,
                        onPlus: () => cart.increment(item.id),
                        onMinus: () => cart.decrement(item.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                const PromoField(),
                const SizedBox(height: 16),
                _Summary(cart: cart),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SwipeToConfirm(
                  label:
                      '${context.tr('swipe_to_order')} · ${Fmt.money(cart.total)}',
                  loading: _placing,
                  onConfirmed: _placeOrder,
                ),
              ),
            ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart});
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value,
            {Color? color, bool bold = false, double size = 15}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: size,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color: bold
                        ? null
                        : context.colors.onSurface.withOpacity(0.65),
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: size,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          row(
            '${context.tr('subtotal')} (${cart.count})',
            Fmt.money(cart.originalSubtotal),
          ),
          if (cart.bookSavings > 0.001)
            row(
              context.tr('discount'),
              '−${Fmt.money(cart.bookSavings)}',
              color: AppColors.sage,
            ),
          if (cart.promoPercent > 0)
            row(
              '${context.tr('promo')} (${cart.promoCode})',
              '−${Fmt.money(cart.promoDiscount)}',
              color: AppColors.sage,
            ),
          const Divider(height: 20),
          row(context.tr('total'), Fmt.money(cart.total), bold: true, size: 20),
        ],
      ),
    );
  }
}
