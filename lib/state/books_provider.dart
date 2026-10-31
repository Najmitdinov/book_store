import 'package:flutter/foundation.dart';

import '../data/models/book.dart';
import '../data/repositories/store_repositories.dart';
import 'load_state.dart';

enum BookSort { popular, newest, priceLow, priceHigh }

/// Kayfiyatlar va ularga mos janr kalit so'zlari (uz / ru / en).
enum Mood {
  cozy('mood_cozy', '☕', ['roman', 'novel', 'роман', 'oila', 'family', 'proza', 'prose', 'проза']),
  adventure('mood_adventure', '🧭', ['sarguzasht', 'adventure', 'приключ', 'fantast', 'fantasy', 'фэнтези', 'фантаст']),
  learn('mood_learn', '🧠', ['ilm', 'science', 'наук', 'biznes', 'business', 'бизнес', 'tarix', 'history', 'истор', 'psix', 'psych', 'псих', 'texn', 'tech', 'дастур', 'program']),
  love('mood_love', '💌', ['muhabbat', 'sevgi', 'love', 'romance', 'любов', 'роман']),
  mystery('mood_mystery', '🕯️', ['detektiv', 'detective', 'детектив', 'triller', 'thriller', 'триллер', 'sir', 'mystery', 'horror', 'ужас']),
  inspire('mood_inspire', '✨', ['motiv', 'мотив', 'shaxsiy', 'self', 'саморазв', 'biograf', 'биограф', 'she\'r', 'poetry', 'поэз', 'стих']);

  const Mood(this.labelKey, this.emoji, this.keywords);
  final String labelKey;
  final String emoji;
  final List<String> keywords;

  bool matches(Book b) {
    final hay = '${b.genre} ${b.title} ${b.description}'.toLowerCase();
    return keywords.any(hay.contains);
  }
}

class BookFilter {
  final String query;
  final String? genre;
  final String? language;
  final bool onlyDiscount;
  final double? maxPrice;
  final BookSort sort;

  const BookFilter({
    this.query = '',
    this.genre,
    this.language,
    this.onlyDiscount = false,
    this.maxPrice,
    this.sort = BookSort.popular,
  });

  bool get isActive =>
      genre != null || language != null || onlyDiscount || maxPrice != null;

  int get activeCount =>
      (genre != null ? 1 : 0) +
      (language != null ? 1 : 0) +
      (onlyDiscount ? 1 : 0) +
      (maxPrice != null ? 1 : 0);

  BookFilter copyWith({
    String? query,
    String? genre,
    String? language,
    bool? onlyDiscount,
    double? maxPrice,
    BookSort? sort,
    bool clearGenre = false,
    bool clearLanguage = false,
    bool clearMaxPrice = false,
  }) =>
      BookFilter(
        query: query ?? this.query,
        genre: clearGenre ? null : (genre ?? this.genre),
        language: clearLanguage ? null : (language ?? this.language),
        onlyDiscount: onlyDiscount ?? this.onlyDiscount,
        maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
        sort: sort ?? this.sort,
      );
}

class BooksProvider extends ChangeNotifier with LoadStateMixin {
  BooksProvider(this._repo);

  final BookRepository _repo;

  List<Book> _books = [];
  BookFilter _filter = const BookFilter();

  List<Book> get books => List.unmodifiable(_books);
  BookFilter get filter => _filter;
  bool get isEmpty => _books.isEmpty;

  Future<void> load({bool force = false}) async {
    if (isLoading) return;
    if (status == LoadStatus.ready && !force) return;
    status = LoadStatus.loading;
    errorCode = null;
    notifyListeners();
    try {
      _books = await _repo.fetchAll();
      status = LoadStatus.ready;
    } catch (e) {
      errorCode = LoadStateMixin.codeOf(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _books = [];
    _filter = const BookFilter();
    status = LoadStatus.idle;
    notifyListeners();
  }

  Book? findById(String id) {
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  List<Book> byIds(Iterable<String> ids) =>
      ids.map(findById).whereType<Book>().toList();

  // ---- Kolleksiyalar (asosiy sahifa) ----

  List<Book> get popular => [..._books]
    ..sort((a, b) => b.popularity.compareTo(a.popularity));

  List<Book> get newest => [..._books]..sort((a, b) => b.date.compareTo(a.date));

  List<Book> get onSale => _books.where((b) => b.hasDiscount).toList()
    ..sort((a, b) => b.discount.compareTo(a.discount));

  /// Kunning kitobi — sana bo'yicha deterministik, kun davomida o'zgarmaydi.
  Book? get bookOfTheDay {
    if (_books.isEmpty) return null;
    final now = DateTime.now();
    final seed = now.year * 1000 + now.month * 40 + now.day;
    final sorted = [..._books]..sort((a, b) => a.id.compareTo(b.id));
    return sorted[seed % sorted.length];
  }

  List<Book> byMood(Mood mood) {
    final matched = _books.where(mood.matches).toList()
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
    return matched;
  }

  /// Sevimli kitoblar janrlariga asoslangan tavsiyalar.
  List<Book> recommendedFor(Set<String> favoriteIds) {
    final favGenres = byIds(favoriteIds)
        .map((b) => b.genre.toLowerCase())
        .where((g) => g.isNotEmpty)
        .toSet();
    if (favGenres.isEmpty) return popular.take(8).toList();
    final list = _books
        .where((b) =>
            !favoriteIds.contains(b.id) &&
            favGenres.contains(b.genre.toLowerCase()))
        .toList()
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
    return list.isEmpty ? popular.take(8).toList() : list;
  }

  List<Book> similarTo(Book book) => _books
      .where((b) =>
          b.id != book.id &&
          (b.genre.toLowerCase() == book.genre.toLowerCase() ||
              b.author == book.author))
      .take(10)
      .toList();

  // ---- Qidiruv va filtr ----

  List<String> get genres {
    final set = <String>{};
    for (final b in _books) {
      if (b.genre.trim().isNotEmpty) set.add(b.genre.trim());
    }
    return set.toList()..sort();
  }

  List<String> get languages {
    final set = <String>{};
    for (final b in _books) {
      set.addAll(b.languages.map((l) => l.trim()).where((l) => l.isNotEmpty));
    }
    return set.toList()..sort();
  }

  double get maxBookPrice => _books.isEmpty
      ? 100
      : _books.map((b) => b.finalPrice).reduce((a, b) => a > b ? a : b);

  void setFilter(BookFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setQuery(String q) => setFilter(_filter.copyWith(query: q));

  void clearFilters() =>
      setFilter(BookFilter(query: _filter.query, sort: _filter.sort));

  List<Book> get filtered {
    final q = _filter.query.trim().toLowerCase();
    final list = _books.where((b) {
      if (q.isNotEmpty &&
          !b.title.toLowerCase().contains(q) &&
          !b.author.toLowerCase().contains(q) &&
          !b.genre.toLowerCase().contains(q)) {
        return false;
      }
      if (_filter.genre != null && b.genre.trim() != _filter.genre) {
        return false;
      }
      if (_filter.language != null &&
          !b.languages.map((l) => l.trim()).contains(_filter.language)) {
        return false;
      }
      if (_filter.onlyDiscount && !b.hasDiscount) return false;
      if (_filter.maxPrice != null && b.finalPrice > _filter.maxPrice!) {
        return false;
      }
      return true;
    }).toList();

    switch (_filter.sort) {
      case BookSort.popular:
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
      case BookSort.newest:
        list.sort((a, b) => b.date.compareTo(a.date));
      case BookSort.priceLow:
        list.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
      case BookSort.priceHigh:
        list.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
    }
    return list;
  }

  // ---- Admin amallari ----

  Future<void> create(Book book) async {
    final id = await _repo.create(book);
    _books = [..._books, book.copyWith(id: id)];
    notifyListeners();
  }

  Future<void> update(Book book) async {
    await _repo.update(book);
    _books = _books.map((b) => b.id == book.id ? book : b).toList();
    notifyListeners();
  }

  /// Optimistik o'chirish: xato bo'lsa kitob joyiga qaytadi.
  Future<void> delete(String id) async {
    final index = _books.indexWhere((b) => b.id == id);
    if (index < 0) return;
    final removed = _books[index];
    _books = [..._books]..removeAt(index);
    notifyListeners();
    try {
      await _repo.delete(id);
    } catch (_) {
      _books = [..._books]..insert(index.clamp(0, _books.length), removed);
      notifyListeners();
      rethrow;
    }
  }
}
