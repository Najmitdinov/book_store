import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_card.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../data/models/shelf_entry.dart';
import '../../state/auth_provider.dart';
import '../../state/books_provider.dart';
import '../../state/library_provider.dart';
import '../../state/load_state.dart';
import '../../state/wishlist_provider.dart';
import '../shell/main_shell.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Mood? _mood;

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'greeting_morning';
    if (h >= 12 && h < 18) return 'greeting_day';
    if (h >= 18 && h < 23) return 'greeting_evening';
    return 'greeting_night';
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>();
    final library = context.watch<LibraryProvider>();
    final favorites = context.watch<WishlistProvider>().ids;
    final name = context.select<AuthProvider, String>((a) => a.displayName);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => books.load(force: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(name)),
              SliverToBoxAdapter(child: _searchPill()),
              ..._content(books, library, favorites),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.tr(_greetingKey())}, $name 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('home_subtitle'),
                  style: TextStyle(
                    color: context.colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const CartButton(),
        ],
      ),
    );
  }

  Widget _searchPill() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => MainShell.of(context)?.goTo(1),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: context.colors.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('search_hint'),
                style: TextStyle(
                  color: context.colors.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    BooksProvider books,
    LibraryProvider library,
    Set<String> favorites,
  ) {
    if (books.status == LoadStatus.idle ||
        (books.isLoading && books.isEmpty)) {
      return const [
        SliverFillRemaining(hasScrollBody: true, child: HomeSkeleton()),
      ];
    }
    if (books.hasError && books.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            code: books.errorCode,
            onRetry: () => books.load(force: true),
          ),
        ),
      ];
    }
    if (books.isEmpty) {
      final isAdmin = context.read<AuthProvider>().isAdmin;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            emoji: '📚',
            title: context.tr('no_books'),
            subtitle: isAdmin ? context.tr('no_books_admin') : null,
            action: isAdmin
                ? SizedBox(
                    width: 220,
                    child: FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(Routes.editBook),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(context.tr('add_book')),
                    ),
                  )
                : null,
          ),
        ),
      ];
    }

    final reading = library
        .onShelf(Shelf.reading)
        .map((e) => (entry: e, book: books.findById(e.bookId)))
        .where((x) => x.book != null)
        .toList();
    final recent = books.byIds(library.recentIds);
    final botd = books.bookOfTheDay;

    return [
      if (botd != null) SliverToBoxAdapter(child: BookOfTheDayCard(book: botd)),
      if (reading.isNotEmpty)
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: context.tr('shelf_reading')),
              SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: reading.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => ContinueReadingCard(
                    book: reading[i].book!,
                    entry: reading[i].entry,
                  ),
                ),
              ),
            ],
          ),
        ),
      SliverToBoxAdapter(child: _moodSection(books)),
      SliverToBoxAdapter(
        child: BookCarousel(
          title: context.tr('for_you'),
          books: books.recommendedFor(favorites),
          heroPrefix: 'foryou',
        ),
      ),
      SliverToBoxAdapter(
        child: BookCarousel(
          title: context.tr('popular'),
          books: books.popular,
          heroPrefix: 'popular',
        ),
      ),
      SliverToBoxAdapter(
        child: BookCarousel(
          title: context.tr('new_arrivals'),
          books: books.newest,
          heroPrefix: 'new',
        ),
      ),
      SliverToBoxAdapter(
        child: BookCarousel(
          title: context.tr('on_sale'),
          books: books.onSale,
          heroPrefix: 'sale',
        ),
      ),
      SliverToBoxAdapter(
        child: BookCarousel(
          title: context.tr('recently_viewed'),
          books: recent,
          heroPrefix: 'recent',
        ),
      ),
    ];
  }

  Widget _moodSection(BooksProvider books) {
    final List<Book> moodBooks = _mood == null ? const [] : books.byMood(_mood!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.tr('mood_title')),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: Mood.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final mood = Mood.values[i];
              final selected = mood == _mood;
              return ChoiceChip(
                label: Text('${mood.emoji}  ${context.tr(mood.labelKey)}'),
                selected: selected,
                showCheckmark: false,
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) =>
                    setState(() => _mood = selected ? null : mood),
              );
            },
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _mood == null
              ? const SizedBox(width: double.infinity)
              : moodBooks.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        context.tr('nothing_found'),
                        style: TextStyle(
                          color: context.colors.onSurface.withOpacity(0.55),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        height: 300,
                        child: ListView.separated(
                          key: ValueKey(_mood),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: moodBooks.length.clamp(0, 12),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (_, i) => BookCard(
                            book: moodBooks[i],
                            heroPrefix: 'mood',
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
