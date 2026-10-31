import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/book_card.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../state/books_provider.dart';
import '../../state/load_state.dart';
import '../catalog/catalog_view.dart';
import '../home/book_list_screen.dart';
import '../shell/main_shell.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  /// Qiymat oshirilsa — "Global katalog" tabi ochiladi.
  static final openCatalog = ValueNotifier<int>(0);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  late final _tabs = TabController(length: 2, vsync: this);
  Timer? _debounce;
  bool _grid = true;

  @override
  void initState() {
    super.initState();
    ExploreScreen.openCatalog.addListener(_showCatalog);
  }

  void _showCatalog() => _tabs.animateTo(1);

  @override
  void dispose() {
    ExploreScreen.openCatalog.removeListener(_showCatalog);
    _tabs.dispose();
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQuery(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<BooksProvider>().setQuery(q);
    });
    setState(() {}); // tozalash tugmasini ko'rsatish uchun
  }

  String _sortLabel(BookSort s) => context.tr(switch (s) {
        BookSort.popular => 'sort_popular',
        BookSort.newest => 'sort_new',
        BookSort.priceLow => 'sort_price_low',
        BookSort.priceHigh => 'sort_price_high',
      });

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>();
    final filter = books.filter;
    final results = books.filtered;

    final storeTab = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: _onQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: context.tr('search_hint'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _search.clear();
                                _onQuery('');
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _FilterButton(
                  count: filter.activeCount,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _FilterSheet(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('results_count', {'n': '${results.length}'}),
                    style: TextStyle(
                      color: context.colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                PopupMenuButton<BookSort>(
                  initialValue: filter.sort,
                  onSelected: (s) => books.setFilter(filter.copyWith(sort: s)),
                  itemBuilder: (_) => BookSort.values
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text(_sortLabel(s)),
                          ))
                      .toList(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_vert_rounded, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _sortLabel(filter.sort),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _grid ? 'List' : 'Grid',
                  onPressed: () => setState(() => _grid = !_grid),
                  icon: Icon(
                    _grid ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                  ),
                ),
              ],
            ),
          ),
          if (filter.isActive) _ActiveFilters(filter: filter),
          Expanded(child: _results(books, results)),
        ],
      );

    return Scaffold(
        appBar: AppBar(
          title: Text(context.tr('explore_title')),
          actions: const [CartButton()],
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            labelStyle: const TextStyle(
              fontFamily: 'Maat_Rounded',
              fontWeight: FontWeight.w800,
            ),
            tabs: [
              Tab(
                icon: const Icon(Icons.storefront_rounded),
                text: context.tr('tab_store'),
              ),
              Tab(
                icon: const Icon(Icons.public_rounded),
                text: context.tr('tab_global'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            Padding(padding: const EdgeInsets.only(top: 12), child: storeTab),
            const CatalogView(),
          ],
        ),
    );
  }

  Widget _results(BooksProvider books, List<Book> results) {
    if (books.isLoading && books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (books.status == LoadStatus.error && books.isEmpty) {
      return ErrorView(
        code: books.errorCode,
        onRetry: () => books.load(force: true),
      );
    }
    if (results.isEmpty) {
      return EmptyState(
        emoji: '🔍',
        title: context.tr('nothing_found'),
        subtitle: context.tr('nothing_found_hint'),
        action: books.filter.isActive || books.filter.query.isNotEmpty
            ? OutlinedButton(
                onPressed: () {
                  _search.clear();
                  books.setFilter(const BookFilter());
                  setState(() {});
                },
                child: Text(context.tr('reset')),
              )
            : null,
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _grid
          ? BookGrid(
              key: const ValueKey('grid'),
              books: results,
              heroPrefix: 'explore',
            )
          : ListView.separated(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => BookTile(
                book: results[i],
                heroPrefix: 'explore-list',
              ),
            ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: count > 0 ? AppColors.accent : context.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 54,
          height: 54,
          child: Badge(
            isLabelVisible: count > 0,
            backgroundColor: AppColors.ink,
            label: Text('$count'),
            offset: const Offset(-6, 6),
            child: Center(
              child: Icon(
                Icons.tune_rounded,
                color: count > 0 ? Colors.white : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.filter});
  final BookFilter filter;

  @override
  Widget build(BuildContext context) {
    final books = context.read<BooksProvider>();
    final chips = <Widget>[
      if (filter.genre != null)
        InputChip(
          label: Text(filter.genre!),
          onDeleted: () => books.setFilter(filter.copyWith(clearGenre: true)),
        ),
      if (filter.language != null)
        InputChip(
          label: Text(filter.language!.toUpperCase()),
          onDeleted: () =>
              books.setFilter(filter.copyWith(clearLanguage: true)),
        ),
      if (filter.onlyDiscount)
        InputChip(
          label: Text(context.tr('only_discount')),
          onDeleted: () => books.setFilter(filter.copyWith(onlyDiscount: false)),
        ),
      if (filter.maxPrice != null)
        InputChip(
          label: Text('≤ ${Fmt.money(filter.maxPrice!)}'),
          onDeleted: () =>
              books.setFilter(filter.copyWith(clearMaxPrice: true)),
        ),
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late BookFilter _draft = context.read<BooksProvider>().filter;

  @override
  Widget build(BuildContext context) {
    final books = context.read<BooksProvider>();
    final maxPrice = books.maxBookPrice.ceilToDouble().clamp(1.0, 100000.0);
    final currentMax = (_draft.maxPrice ?? maxPrice).clamp(0.0, maxPrice);

    Widget label(String key) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            context.tr(key),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (_, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                Text(
                  context.tr('filters'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (books.genres.isNotEmpty) ...[
                  label('genre'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(context.tr('all')),
                        selected: _draft.genre == null,
                        onSelected: (_) => setState(
                          () => _draft = _draft.copyWith(clearGenre: true),
                        ),
                      ),
                      for (final g in books.genres)
                        ChoiceChip(
                          label: Text(g),
                          selected: _draft.genre == g,
                          onSelected: (_) =>
                              setState(() => _draft = _draft.copyWith(genre: g)),
                        ),
                    ],
                  ),
                ],
                if (books.languages.isNotEmpty) ...[
                  label('language'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(context.tr('all')),
                        selected: _draft.language == null,
                        onSelected: (_) => setState(
                          () => _draft = _draft.copyWith(clearLanguage: true),
                        ),
                      ),
                      for (final l in books.languages)
                        ChoiceChip(
                          label: Text(l.toUpperCase()),
                          selected: _draft.language == l,
                          onSelected: (_) => setState(
                            () => _draft = _draft.copyWith(language: l),
                          ),
                        ),
                    ],
                  ),
                ],
                label('price_range'),
                Row(
                  children: [
                    Text(Fmt.money(0)),
                    Expanded(
                      child: Slider(
                        value: currentMax,
                        min: 0,
                        max: maxPrice,
                        activeColor: AppColors.accent,
                        label: Fmt.money(currentMax),
                        divisions: maxPrice.round().clamp(1, 200),
                        onChanged: (v) => setState(
                          () => _draft = v >= maxPrice
                              ? _draft.copyWith(clearMaxPrice: true)
                              : _draft.copyWith(maxPrice: v),
                        ),
                      ),
                    ),
                    Text(Fmt.money(currentMax)),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.accent,
                  title: Text(context.tr('only_discount')),
                  value: _draft.onlyDiscount,
                  onChanged: (v) =>
                      setState(() => _draft = _draft.copyWith(onlyDiscount: v)),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(
                        () => _draft = BookFilter(
                          query: _draft.query,
                          sort: _draft.sort,
                        ),
                      ),
                      child: Text(context.tr('reset')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        books.setFilter(_draft);
                        Navigator.pop(context);
                      },
                      child: Text(context.tr('apply')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
