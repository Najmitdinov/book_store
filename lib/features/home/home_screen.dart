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
import '../../state/catalog_provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CatalogProvider>().loadHome(),
    );
  }

  /// Ochiq kataloglardan kolleksiyalar — do'kon bo'sh bo'lsa ham kitoblar chiqadi.
  List<Widget> _global(CatalogProvider catalog) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Row(
            children: [
              const Icon(Icons.public_rounded, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                context.tr('global_section'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(color: AppColors.accent.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      ),
      for (final shelf in CatalogShelf.values)
        SliverToBoxAdapter(
          child: ExternalCarousel(
            title: context.tr(shelf.titleKey),
            books: catalog.shelf(shelf),
            loading: catalog.shelfLoading(shelf),
            onSeeAll: () {
              catalog.browse(shelf.source, shelf.sort);
              MainShell.of(context)?.goTo(1, catalogTab: true);
            },
          ),
        ),
    ];
  }

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
    final catalog = context.watch<CatalogProvider>();
    final name = context.select<AuthProvider, String>((a) => a.displayName);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => Future.wait([
            books.load(force: true),
            catalog.loadHome(force: true),
          ]),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(name)),
              SliverToBoxAdapter(child: _searchPill()),
              ..._content(books, library, favorites),
              ..._global(catalog),
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
        SliverToBoxAdapter(child: SizedBox(height: 520, child: HomeSkeleton())),
      ];
    }
    if (books.hasError && books.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: ErrorView(
              code: books.errorCode,
              onRetry: () => books.load(force: true),
            ),
          ),
        ),
      ];
    }
    if (books.isEmpty) {
      final isAdmin = context.read<AuthProvider>().isAdmin;
      return [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('global_store_empty'),
                  style: const TextStyle(height: 1.4),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.editBook),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.tr('add_book')),
                  ),
                ],
              ],
            ),
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
