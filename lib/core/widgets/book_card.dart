import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/book.dart';
import '../../state/wishlist_provider.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'book_cover.dart';
import 'common.dart';

void openBook(BuildContext context, Book book, {String? heroTag}) =>
    Navigator.of(context).pushNamed(
      Routes.details,
      arguments: DetailsArgs(bookId: book.id, heroTag: heroTag),
    );

/// Vertikal kitob kartasi — karusel va to'rlar uchun.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.width = 140,
    this.heroPrefix = 'card',
  });

  final Book book;
  final double width;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => openBook(context, book, heroTag: '$heroPrefix-${book.id}'),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muqova bo'sh joyni egallaydi — karta istalgan balandlikka moslashadi.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BookCover(book: book, heroTag: '$heroPrefix-${book.id}'),
                  if (book.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 10,
                      child: _Badge(text: '-${book.discount}%'),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: WishlistButton(bookId: book.id, compact: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: PriceTag(
                    price: book.finalPrice,
                    originalPrice: book.hasDiscount ? book.price : null,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 2),
                Text(
                  Fmt.rating(book.popularity),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Gorizontal ro'yxat elementi — izlash natijalari va javon uchun.
class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
    this.trailing,
    this.subtitle,
    this.heroPrefix = 'tile',
  });

  final Book book;
  final Widget? trailing;
  final Widget? subtitle;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openBook(context, book, heroTag: '$heroPrefix-${book.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              book: book,
              width: 70,
              height: 105,
              radius: 10,
              showShadow: false,
              heroTag: '$heroPrefix-${book.id}',
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.genre.isNotEmpty)
                    Text(
                      book.genre.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurface.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 8),
                  subtitle ??
                      Row(
                        children: [
                          RatingStars(rating: book.popularity, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            '${book.pageLength} ${context.tr('pages')}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  context.colors.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 6),
                  PriceTag(
                    price: book.finalPrice,
                    originalPrice: book.hasDiscount ? book.price : null,
                    fontSize: 15,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Yurakcha tugmasi — bosilganda "urib" ketadigan animatsiya bilan.
class WishlistButton extends StatefulWidget {
  const WishlistButton({super.key, required this.bookId, this.compact = false});

  final String bookId;
  final bool compact;

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    lowerBound: 0.8,
    upperBound: 1.25,
    value: 1,
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final wishlist = context.read<WishlistProvider>();
    _anim.forward(from: 0.8).then((_) {
      if (mounted) _anim.animateTo(1);
    });
    try {
      final added = await wishlist.toggle(widget.bookId);
      if (!mounted) return;
      showSnack(
        context,
        context.tr(added ? 'added_to_wishlist' : 'removed_from_wishlist'),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = context.select<WishlistProvider, bool>(
      (w) => w.contains(widget.bookId),
    );
    final icon = ScaleTransition(
      scale: _anim,
      child: Icon(
        active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: active ? AppColors.accent : (widget.compact ? Colors.white : null),
        size: widget.compact ? 20 : 26,
      ),
    );
    if (widget.compact) {
      return GestureDetector(
        onTap: _toggle,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
      );
    }
    return IconButton(onPressed: _toggle, icon: icon);
  }
}
