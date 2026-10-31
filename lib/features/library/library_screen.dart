import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_card.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../data/models/shelf_entry.dart';
import '../../state/books_provider.dart';
import '../../state/library_provider.dart';
import '../../state/wishlist_provider.dart';
import '../shell/main_shell.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              title: Text(context.tr('library_title')),
              actions: const [CartButton()],
            ),
            const SliverToBoxAdapter(child: GoalCard()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsDelegate(
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: context.colors.onSurface,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: [
                    Tab(text: context.tr('tab_wishlist'), height: 38),
                    Tab(text: context.tr('shelf_reading'), height: 38),
                    Tab(text: context.tr('shelf_want'), height: 38),
                    Tab(text: context.tr('shelf_finished'), height: 38),
                  ],
                ),
                background: context.colors.surface,
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _WishlistTab(),
              _ShelfTab(shelf: Shelf.reading),
              _ShelfTab(shelf: Shelf.want),
              _ShelfTab(shelf: Shelf.finished),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  _TabsDelegate(this.tabBar, {required this.background});
  final TabBar tabBar;
  final Color background;

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabsDelegate old) =>
      old.tabBar != tabBar || old.background != background;
}

/// Yillik maqsadni tahrirlash dialogi (javon va profil ekranlarida ishlatiladi).
Future<void> showGoalEditor(BuildContext context, LibraryProvider library) async {
  var value = library.goal.clamp(1, 100).toDouble();
  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(ctx.tr('reading_goal')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${value.round()}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
            Text(ctx.tr('books_unit')),
            Slider(
              value: value,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: AppColors.accent,
              onChanged: (v) => setState(() => value = v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, value.round()),
            child: Text(ctx.tr('save')),
          ),
        ],
      ),
    ),
  );
  if (result == null) return;
  try {
    await library.setGoal(result);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// Yillik o'qish maqsadi — animatsion halqa va seriya.
class GoalCard extends StatelessWidget {
  const GoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final done = library.finishedThisYear;
    final goal = library.goal;
    final left = math.max(0, goal - done);
    final streak = library.streak;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: context.isDark
                ? [AppColors.nightCard, AppColors.nightSurface]
                : [AppColors.ink, const Color(0xFF3A332B)],
          ),
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: library.goalProgress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => SizedBox(
                width: 92,
                height: 92,
                child: CustomPaint(
                  painter: _RingPainter(v),
                  child: Center(
                    child: Text(
                      '${(v * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('goal_title', {'year': '${DateTime.now().year}'}),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('goal_progress', {
                      'done': '$done',
                      'goal': '$goal',
                    }),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    left == 0
                        ? context.tr('goal_done')
                        : context.tr('goal_left', {'n': '$left'}),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (streak > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🔥 ${context.tr('streak', {'n': '$streak'})}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => showGoalEditor(context, library),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.tr('set_goal'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = const SweepGradient(
          colors: [AppColors.accent, AppColors.gold, AppColors.accent],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _WishlistTab extends StatelessWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final books = context.watch<BooksProvider>().byIds(wishlist.ids);

    if (wishlist.isLoading && books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (books.isEmpty) {
      return EmptyState(emoji: '💛', title: context.tr('wishlist_empty'));
    }
    return _BookList(books: books, heroPrefix: 'wish');
  }
}

class _ShelfTab extends StatelessWidget {
  const _ShelfTab({required this.shelf});
  final Shelf shelf;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final booksProvider = context.watch<BooksProvider>();
    final entries = library.onShelf(shelf);
    final pairs = entries
        .map((e) => (entry: e, book: booksProvider.findById(e.bookId)))
        .where((p) => p.book != null)
        .toList();

    if (library.isLoading && pairs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (pairs.isEmpty) {
      return EmptyState(
        emoji: switch (shelf) {
          Shelf.want => '🔖',
          Shelf.reading => '📖',
          Shelf.finished => '🏆',
        },
        title: context.tr('shelf_empty'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: pairs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final book = pairs[i].book!;
        final entry = pairs[i].entry;
        return BookTile(
          book: book,
          heroPrefix: 'shelf-${shelf.value}',
          subtitle: shelf == Shelf.reading && book.pageLength > 0
              ? _MiniProgress(book: book, entry: entry)
              : null,
        );
      },
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.book, required this.entry});
  final Book book;
  final ShelfEntry entry;

  @override
  Widget build(BuildContext context) {
    final p = (entry.currentPage / book.pageLength).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: p,
            minHeight: 6,
            color: AppColors.sage,
            backgroundColor: context.colors.onSurface.withOpacity(0.08),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('progress_page', {
            'n': '${entry.currentPage}',
            'm': '${book.pageLength}',
          }),
          style: TextStyle(
            fontSize: 12,
            color: context.colors.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList({required this.books, required this.heroPrefix});
  final List<Book> books;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => BookTile(
        book: books[i],
        heroPrefix: heroPrefix,
        trailing: WishlistButton(bookId: books[i].id),
      ),
    );
  }
}
