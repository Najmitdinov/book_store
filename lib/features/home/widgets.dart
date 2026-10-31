import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_card.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../data/models/shelf_entry.dart';

class BookCarousel extends StatelessWidget {
  const BookCarousel({
    super.key,
    required this.title,
    required this.books,
    required this.heroPrefix,
    this.limit = 10,
  });

  final String title;
  final List<Book> books;
  final String heroPrefix;
  final int limit;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();
    final shown = books.take(limit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAll: books.length > 3
              ? () => Navigator.of(context).pushNamed(
                    Routes.bookList,
                    arguments: BookListArgs(title: title, books: books),
                  )
              : null,
        ),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) =>
                BookCard(book: shown[i], heroPrefix: heroPrefix),
          ),
        ),
      ],
    );
  }
}

/// "Kunning kitobi" — kitob rangida bo'yalgan katta karta.
class BookOfTheDayCard extends StatelessWidget {
  const BookOfTheDayCard({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final base = book.bgColor;
    final dark = Color.lerp(base, Colors.black, 0.45)!;
    final onColor =
        base.computeLuminance() > 0.55 ? AppColors.ink : Colors.white;
    const tag = 'botd';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: () => openBook(context, book, heroTag: '$tag-${book.id}'),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, dark],
            ),
            boxShadow: [
              BoxShadow(
                color: base.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dekorativ doiralar
              Positioned(
                right: -40,
                top: -40,
                child: _Circle(size: 160, color: onColor.withOpacity(0.07)),
              ),
              Positioned(
                left: -30,
                bottom: -50,
                child: _Circle(size: 120, color: onColor.withOpacity(0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: onColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '☀️ ${context.tr('book_of_day')}',
                              style: TextStyle(
                                color: onColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: onColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: onColor.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 16, color: onColor.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text(
                                context.tr('reading_time',
                                    {'h': '${book.readingHours}'}),
                                style: TextStyle(
                                  color: onColor.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.star_rounded,
                                  size: 16, color: AppColors.gold),
                              const SizedBox(width: 2),
                              Text(
                                book.popularity.toStringAsFixed(1),
                                style: TextStyle(color: onColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Transform.rotate(
                      angle: 0.06,
                      child: BookCover(
                        book: book,
                        width: 112,
                        height: 168,
                        heroTag: '$tag-${book.id}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

/// "Davom ettirish" kartasi — o'qilayotgan kitob va jarayon chizig'i.
class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({
    super.key,
    required this.book,
    required this.entry,
  });

  final Book book;
  final ShelfEntry entry;

  @override
  Widget build(BuildContext context) {
    final total = book.pageLength <= 0 ? 1 : book.pageLength;
    final progress = (entry.currentPage / total).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () => openBook(context, book, heroTag: 'continue-${book.id}'),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            BookCover(
              book: book,
              width: 56,
              height: 84,
              radius: 8,
              showShadow: false,
              heroTag: 'continue-${book.id}',
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor:
                          context.colors.onSurface.withOpacity(0.08),
                      color: AppColors.sage,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).round()}% · ${context.tr('progress_page', {
                          'n': '${entry.currentPage}',
                          'm': '${book.pageLength}',
                        })}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Skeleton(height: 210, radius: 28),
        const SizedBox(height: 28),
        const Skeleton(width: 160, height: 20),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            3,
            (_) => const Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Skeleton(height: 190),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Skeleton(width: 140, height: 20),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            3,
            (_) => const Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Skeleton(height: 190),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
