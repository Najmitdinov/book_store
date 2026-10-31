import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/external_book_card.dart';
import '../../data/models/external_book.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../state/catalog_provider.dart';
import '../../state/load_state.dart';

/// Global katalog: Open Library, Project Gutenberg va Google Books bo'yicha
/// jonli qidiruv, cheksiz aylantirish bilan.
class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView>
    with AutomaticKeepAliveClientMixin {
  late final _search =
      TextEditingController(text: context.read<CatalogProvider>().query);
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) {
        context.read<CatalogProvider>().loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CatalogProvider>().ensureLoaded(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CatalogProvider>().setQuery(q);
    });
    setState(() {});
  }

  String _sortLabel(CatalogSort s) => context.tr(switch (s) {
        CatalogSort.relevance => 'sort_relevance',
        CatalogSort.newest => 'sort_new',
        CatalogSort.oldest => 'sort_old',
        CatalogSort.popular => 'sort_popular',
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final catalog = context.watch<CatalogProvider>();
    final results = catalog.results;

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _search,
              onChanged: _onQuery,
              textInputAction: TextInputAction.search,
              onSubmitted: (q) {
                _debounce?.cancel();
                catalog.setQuery(q);
              },
              decoration: InputDecoration(
                hintText: context.tr('catalog_hint'),
                prefixIcon: const Icon(Icons.travel_explore_rounded),
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
        ),
        SliverToBoxAdapter(
          child: _ChipRow(
            children: [
              for (final s in CatalogSource.values)
                ChoiceChip(
                  label: Text(s.label),
                  selected: catalog.source == s,
                  showCheckmark: false,
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(
                    color: catalog.source == s ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => catalog.setSource(s),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _ChipRow(
            children: [
              for (final s in CatalogSort.values)
                ChoiceChip(
                  label: Text(_sortLabel(s)),
                  selected: catalog.sort == s,
                  onSelected: (_) => catalog.setSort(s),
                ),
              const SizedBox(width: 8),
              for (final lang in const [null, 'uz', 'ru', 'en'])
                ChoiceChip(
                  label: Text(lang == null ? '🌐 ${context.tr('all')}' : lang.toUpperCase()),
                  selected: catalog.language == lang,
                  onSelected: (_) => catalog.setLanguage(lang),
                ),
            ],
          ),
        ),
        if (catalog.total != null && catalog.total! > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                context.tr('results_count', {'n': _compact(catalog.total!)}),
                style: TextStyle(
                  color: context.colors.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        if (catalog.isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (catalog.status == LoadStatus.error)
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(code: catalog.errorCode, onRetry: catalog.search),
          )
        else if (results.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              emoji: '🔍',
              title: context.tr('nothing_found'),
              subtitle: context.tr('nothing_found_hint'),
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                mainAxisExtent: 320,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => LayoutBuilder(
                  builder: (_, c) =>
                      ExternalBookCard(book: results[i], width: c.maxWidth),
                ),
                childCount: results.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Center(
                child: catalog.loadingMore
                    ? const CircularProgressIndicator()
                    : catalog.hasMore
                        ? OutlinedButton(
                            onPressed: catalog.loadMore,
                            child: Text(context.tr('load_more')),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}
