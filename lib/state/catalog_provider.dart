import 'package:flutter/foundation.dart';

import '../data/models/external_book.dart';
import '../data/repositories/catalog_repository.dart';
import 'load_state.dart';

/// Asosiy sahifadagi global kolleksiyalar.
enum CatalogShelf {
  newReleases('global_new', CatalogSource.openLibrary, CatalogSort.newest),
  classics('global_classics', CatalogSource.gutenberg, CatalogSort.popular),
  historic('global_historic', CatalogSource.openLibrary, CatalogSort.oldest),
  trending('global_trending', CatalogSource.google, CatalogSort.newest);

  const CatalogShelf(this.titleKey, this.source, this.sort);
  final String titleKey;
  final CatalogSource source;
  final CatalogSort sort;
}

class CatalogProvider extends ChangeNotifier with LoadStateMixin {
  CatalogProvider(this._repo);

  final CatalogRepository _repo;

  // ---- Qidiruv ----
  CatalogSource _source = CatalogSource.openLibrary;
  CatalogSort _sort = CatalogSort.relevance;
  String _query = '';
  String? _language;
  final List<ExternalBook> _results = [];
  int _page = 1;
  bool _hasMore = false;
  bool _loadingMore = false;
  int? _total;
  int _requestId = 0;

  CatalogSource get source => _source;
  CatalogSort get sort => _sort;
  String get query => _query;
  String? get language => _language;
  List<ExternalBook> get results => List.unmodifiable(_results);
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;
  int? get total => _total;

  // ---- Asosiy sahifa kolleksiyalari ----
  final Map<CatalogShelf, List<ExternalBook>> _shelves = {};
  final Set<CatalogShelf> _shelvesLoading = {};
  bool _homeRequested = false;

  List<ExternalBook> shelf(CatalogShelf s) => _shelves[s] ?? const [];
  bool shelfLoading(CatalogShelf s) => _shelvesLoading.contains(s);

  final Map<String, String?> _descriptions = {};

  Future<void> loadHome({bool force = false}) async {
    if (_homeRequested && !force) return;
    _homeRequested = true;
    await Future.wait(CatalogShelf.values.map(_loadShelf));
  }

  Future<void> _loadShelf(CatalogShelf s) async {
    _shelvesLoading.add(s);
    notifyListeners();
    try {
      final page = await _repo.search(source: s.source, sort: s.sort);
      _shelves[s] = page.books.where((b) => b.coverUrl != null).toList();
    } catch (_) {
      _shelves[s] ??= const [];
    } finally {
      _shelvesLoading.remove(s);
      notifyListeners();
    }
  }

  void setSource(CatalogSource s) {
    if (s == _source) return;
    _source = s;
    search();
  }

  /// Asosiy sahifadagi "Barchasi" — manba va saralashni birdaniga o'rnatadi.
  void browse(CatalogSource source, CatalogSort sort) {
    _source = source;
    _sort = sort;
    _query = '';
    search();
  }

  void setSort(CatalogSort s) {
    if (s == _sort) return;
    _sort = s;
    search();
  }

  void setLanguage(String? lang) {
    if (lang == _language) return;
    _language = lang;
    search();
  }

  void setQuery(String q) {
    if (q.trim() == _query) return;
    _query = q.trim();
    search();
  }

  /// Yangi qidiruv (1-sahifadan). Eski so'rov javobi kech kelsa — tashlanadi.
  Future<void> search() async {
    final id = ++_requestId;
    status = LoadStatus.loading;
    errorCode = null;
    _results.clear();
    _page = 1;
    _hasMore = false;
    _loadingMore = false;
    _total = null;
    notifyListeners();
    try {
      final page = await _repo.search(
        source: _source,
        query: _query,
        sort: _sort,
        language: _language,
      );
      if (id != _requestId) return;
      _results.addAll(page.books);
      _hasMore = page.hasMore;
      _total = page.total;
      status = LoadStatus.ready;
    } catch (e) {
      if (id != _requestId) return;
      errorCode = LoadStateMixin.codeOf(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> ensureLoaded() async {
    if (status == LoadStatus.idle) await search();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loadingMore || isLoading) return;
    final id = _requestId;
    _loadingMore = true;
    notifyListeners();
    try {
      final page = await _repo.search(
        source: _source,
        query: _query,
        sort: _sort,
        language: _language,
        page: _page + 1,
      );
      if (id != _requestId) return;
      _page++;
      final known = _results.map((b) => b.uniqueKey).toSet();
      _results.addAll(page.books.where((b) => known.add(b.uniqueKey)));
      _hasMore = page.hasMore && page.books.isNotEmpty;
    } catch (_) {
      _hasMore = false;
    } finally {
      if (id == _requestId) {
        _loadingMore = false;
        notifyListeners();
      }
    }
  }

  // ---- Tafsilotlar ----

  String? descriptionFor(ExternalBook b) =>
      b.description ?? _descriptions[b.uniqueKey];

  bool hasDescriptionLoaded(ExternalBook b) =>
      b.description != null || _descriptions.containsKey(b.uniqueKey);

  Future<void> loadDescription(ExternalBook b) async {
    if (hasDescriptionLoaded(b)) return;
    final d = await _repo.fetchDescription(b);
    _descriptions[b.uniqueKey] = d;
    notifyListeners();
  }

  Future<String> fetchText(ExternalBook b) => _repo.fetchText(b);
}
