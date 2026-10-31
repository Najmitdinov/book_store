import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/book_card.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../state/books_provider.dart';
import '../../state/cart_provider.dart';
import '../../state/library_provider.dart';
import '../../state/reviews_provider.dart';
import '../home/widgets.dart';
import 'reviews_section.dart';
import 'shelf_section.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, required this.bookId, this.heroTag});

  final String bookId;
  final String? heroTag;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LibraryProvider>().markViewed(widget.bookId);
      context.read<ReviewsProvider>().load(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>();
    final book = books.findById(widget.bookId);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(emoji: '📕', title: context.tr('nothing_found')),
      );
    }

    final similar = books.similarTo(book);
    final avg = context.select<ReviewsProvider, double?>(
      (r) => r.averageFor(book.id),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HeroHeader(book: book, heroTag: widget.heroTag ?? 'detail-${book.id}'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.genre.isNotEmpty)
                    Text(
                      book.genre.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colors.onSurface.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingStars(rating: avg ?? book.popularity, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        Fmt.rating(avg ?? book.popularity),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(book: book),
                  const SizedBox(height: 24),
                  ShelfSection(book: book),
                  const SizedBox(height: 24),
                  Text(
                    context.tr('description'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    alignment: Alignment.topCenter,
                    child: Text(
                      book.description.isEmpty ? '—' : book.description,
                      maxLines: _expanded ? null : 5,
                      overflow: _expanded ? null : TextOverflow.fade,
                      style: TextStyle(
                        height: 1.6,
                        color: context.colors.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  if (book.description.length > 220)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.accent,
                      ),
                      onPressed: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        context.tr(_expanded ? 'read_less' : 'read_more'),
                      ),
                    ),
                  if (book.publishPlace.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 18,
                          color: context.colors.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${context.tr('publisher_place')}: ${book.publishPlace}',
                          style: TextStyle(
                            color: context.colors.onSurface.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: ReviewsSection(book: book)),
          SliverToBoxAdapter(
            child: BookCarousel(
              title: context.tr('similar_books'),
              books: similar,
              heroPrefix: 'similar-${book.id}',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: _BuyBar(book: book),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.book, required this.heroTag});

  final Book book;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final base = book.bgColor;
    final onColor =
        base.computeLuminance() > 0.55 ? AppColors.ink : Colors.white;

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: base,
      foregroundColor: onColor,
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.2),
          child: BackButton(color: onColor),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.2),
            child: WishlistButton(bookId: book.id),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                base,
                Color.lerp(base, Colors.black, 0.35)!,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: BookCover(
                  book: book,
                  width: 200,
                  height: 300,
                  radius: 16,
                  heroTag: heroTag,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.menu_book_rounded, '${book.pageLength}', context.tr('pages')),
      (Icons.event_rounded, '${book.date.year}', context.tr('published')),
      (
        Icons.translate_rounded,
        book.languages.isEmpty
            ? '—'
            : book.languages.take(3).map((l) => l.toUpperCase()).join(', '),
        context.tr('language_label'),
      ),
      (
        Icons.schedule_rounded,
        '~${book.readingHours}',
        context.tr('hours_read'),
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Icon(items[i].$1, color: AppColors.accent, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[i].$3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              Container(
                width: 1,
                height: 36,
                color: context.colors.onSurface.withOpacity(0.08),
              ),
          ],
        ],
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(book.id);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (book.hasDiscount)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${book.discount}%',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                PriceTag(
                  price: book.finalPrice,
                  originalPrice: book.hasDiscount ? book.price : null,
                  fontSize: 22,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 190,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, a) =>
                  ScaleTransition(scale: a, child: child),
              child: qty == 0
                  ? FilledButton.icon(
                      key: const ValueKey('add'),
                      onPressed: () {
                        cart.add(book);
                        showSnack(
                          context,
                          context.tr('added_to_cart'),
                          actionLabel: context.tr('go_to_cart'),
                          onAction: () =>
                              Navigator.of(context).pushNamed(Routes.cart),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: Text(context.tr('add_to_cart')),
                    )
                  : _Stepper(
                      key: const ValueKey('stepper'),
                      qty: qty,
                      onMinus: () => cart.decrement(book.id),
                      onPlus: () => cart.increment(book.id),
                      onCart: () =>
                          Navigator.of(context).pushNamed(Routes.cart),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    super.key,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
    required this.onCart,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMinus,
            icon: Icon(Icons.remove_rounded, color: context.colors.onPrimary),
          ),
          Expanded(
            child: InkWell(
              onTap: onCart,
              child: Center(
                child: Text(
                  '$qty',
                  style: TextStyle(
                    color: context.colors.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: Icon(Icons.add_rounded, color: context.colors.onPrimary),
          ),
        ],
      ),
    );
  }
}
