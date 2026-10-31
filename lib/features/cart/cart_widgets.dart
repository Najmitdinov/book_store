import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/cart_item.dart';
import '../../state/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onPlus,
    required this.onMinus,
  });

  final CartItem item;
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 92,
              child: item.imgUrl.isEmpty
                  ? Container(color: AppColors.accentSoft)
                  : CachedNetworkImage(
                      imageUrl: item.imgUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.accentSoft,
                        child: const Icon(Icons.menu_book_rounded),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (item.author.isNotEmpty)
                  Text(
                    item.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurface.withOpacity(0.55),
                    ),
                  ),
                const SizedBox(height: 8),
                PriceTag(
                  price: item.price,
                  originalPrice:
                      item.originalPrice > item.price ? item.originalPrice : null,
                  fontSize: 15,
                ),
              ],
            ),
          ),
          Column(
            children: [
              _RoundIcon(icon: Icons.add_rounded, onTap: onPlus),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              _RoundIcon(
                icon: item.quantity <= 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                onTap: onMinus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.onSurface.withOpacity(0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class PromoField extends StatefulWidget {
  const PromoField({super.key});

  @override
  State<PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends State<PromoField> {
  final _controller = TextEditingController();
  bool _checking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    FocusScope.of(context).unfocus();
    if (_controller.text.trim().isEmpty) return;
    setState(() => _checking = true);
    final ok = await context.read<CartProvider>().applyPromo(_controller.text);
    if (!mounted) return;
    setState(() => _checking = false);
    if (!ok) {
      showSnack(context, context.tr('promo_invalid'), error: true);
    } else {
      _controller.clear();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.promoCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.sage.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.sage.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: AppColors.sage),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${cart.promoCode} · ${context.tr('promo_applied', {
                      'p': '${cart.promoPercent}'
                    })}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: cart.removePromo,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      );
    }

    return TextField(
      controller: _controller,
      textCapitalization: TextCapitalization.characters,
      onSubmitted: (_) => _apply(),
      decoration: InputDecoration(
        hintText: context.tr('promo_hint'),
        prefixIcon: const Icon(Icons.local_offer_outlined),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: _checking
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: _apply,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                  ),
                  child: Text(context.tr('promo_apply')),
                ),
        ),
      ),
    );
  }
}

/// "Suring va tasdiqlang" tugmasi — tasodifiy buyurtmalarning oldini oladi.
class SwipeToConfirm extends StatefulWidget {
  const SwipeToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.loading = false,
  });

  final String label;
  final Future<void> Function() onConfirmed;
  final bool loading;

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm>
    with SingleTickerProviderStateMixin {
  static const _height = 62.0;
  static const _knob = 52.0;

  double _drag = 0;
  late final _reset = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  Animation<double>? _resetAnim;

  @override
  void initState() {
    super.initState();
    _reset.addListener(() {
      if (_resetAnim != null) setState(() => _drag = _resetAnim!.value);
    });
  }

  @override
  void dispose() {
    _reset.dispose();
    super.dispose();
  }

  void _animateBack() {
    _resetAnim = Tween(begin: _drag, end: 0.0)
        .animate(CurvedAnimation(parent: _reset, curve: Curves.easeOutBack));
    _reset.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant SwipeToConfirm old) {
    super.didUpdateWidget(old);
    if (old.loading && !widget.loading) _animateBack();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxDrag = c.maxWidth - _knob - (_height - _knob);
        final progress = maxDrag <= 0 ? 0.0 : (_drag / maxDrag).clamp(0.0, 1.0);
        final fg = context.colors.onPrimary;

        return Container(
          height: _height,
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // To'ldirilayotgan fon
              Container(
                width: _knob + (_height - _knob) + _drag,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.3 + 0.7 * progress),
                  borderRadius: BorderRadius.circular(_height / 2),
                ),
              ),
              Center(
                child: widget.loading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: fg,
                        ),
                      )
                    : Opacity(
                        opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: _knob),
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
              ),
              if (!widget.loading)
                Positioned(
                  left: (_height - _knob) / 2 + _drag,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (d) => setState(
                      () => _drag = (_drag + d.delta.dx).clamp(0.0, maxDrag),
                    ),
                    onHorizontalDragEnd: (_) {
                      if (progress > 0.85) {
                        HapticFeedback.heavyImpact();
                        setState(() => _drag = maxDrag);
                        widget.onConfirmed();
                      } else {
                        _animateBack();
                      }
                    },
                    child: Container(
                      width: _knob,
                      height: _knob,
                      decoration: BoxDecoration(
                        color: fg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        progress > 0.85
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
