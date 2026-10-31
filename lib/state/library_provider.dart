import 'package:flutter/foundation.dart';

import '../data/local/local_storage.dart';
import '../data/models/book.dart';
import '../data/models/shelf_entry.dart';
import '../data/repositories/store_repositories.dart';
import 'load_state.dart';

/// Shaxsiy kutubxona: javonlar, o'qish jarayoni, yillik maqsad,
/// o'qish seriyasi va yaqinda ko'rilgan kitoblar.
class LibraryProvider extends ChangeNotifier with LoadStateMixin {
  LibraryProvider({
    required ShelfRepository shelfRepository,
    required ProfileRepository profileRepository,
    required LocalStorage storage,
  })  : _shelfRepo = shelfRepository,
        _profileRepo = profileRepository,
        _storage = storage;

  final ShelfRepository _shelfRepo;
  final ProfileRepository _profileRepo;
  final LocalStorage _storage;

  static const defaultGoal = 12;
  static const _maxRecent = 12;

  String? _uid;
  Map<String, ShelfEntry> _entries = {};
  int _goal = defaultGoal;
  Set<String> _readingDays = {};
  List<String> _recent = [];

  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _entries = {};
    _goal = defaultGoal;
    _readingDays = uid == null ? {} : _storage.readReadingDays(uid);
    _recent = uid == null ? [] : [..._storage.readRecent(uid)];
    status = LoadStatus.idle;
    // ProxyProvider.update build vaqtida chaqiriladi — xabarni keyinga suramiz.
    Future.microtask(() {
      notifyListeners();
      if (uid != null && uid == _uid) load();
    });
  }

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    status = LoadStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _shelfRepo.fetch(uid),
        _profileRepo.fetchReadingGoal(uid),
      ]);
      _entries = results[0] as Map<String, ShelfEntry>;
      _goal = (results[1] as int?) ?? defaultGoal;
      status = LoadStatus.ready;
    } catch (e) {
      errorCode = LoadStateMixin.codeOf(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  // ---- O'qish ----

  ShelfEntry? entryFor(String bookId) => _entries[bookId];

  List<ShelfEntry> onShelf(Shelf shelf) => _entries.values
      .where((e) => e.shelf == shelf)
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  int get goal => _goal;

  int get finishedThisYear {
    final year = DateTime.now().year;
    return _entries.values
        .where((e) =>
            e.shelf == Shelf.finished &&
            (e.finishedAt ?? e.updatedAt).year == year)
        .length;
  }

  int get finishedTotal =>
      _entries.values.where((e) => e.shelf == Shelf.finished).length;

  double get goalProgress =>
      _goal <= 0 ? 0 : (finishedThisYear / _goal).clamp(0.0, 1.0);

  /// Ketma-ket o'qilgan kunlar soni (bugun yoki kechadan boshlab).
  int get streak {
    var day = DateTime.now();
    if (!_readingDays.contains(_key(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (_readingDays.contains(_key(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  Future<void> setShelf(Book book, Shelf shelf) async {
    final now = DateTime.now();
    final current = _entries[book.id];
    final entry = (current ??
            ShelfEntry(bookId: book.id, shelf: shelf, updatedAt: now))
        .copyWith(
      shelf: shelf,
      updatedAt: now,
      currentPage: shelf == Shelf.finished ? book.pageLength : null,
      finishedAt: shelf == Shelf.finished ? now : null,
      clearFinished: shelf != Shelf.finished,
    );
    await _save(entry, previous: current);
    if (shelf == Shelf.finished) _markReadingDay();
  }

  Future<void> updateProgress(Book book, int page) async {
    final now = DateTime.now();
    final total = book.pageLength > 0 ? book.pageLength : page;
    final clamped = page.clamp(0, total);
    final finished = total > 0 && clamped >= total;
    final current = _entries[book.id];
    final entry = (current ??
            ShelfEntry(bookId: book.id, shelf: Shelf.reading, updatedAt: now))
        .copyWith(
      currentPage: clamped,
      updatedAt: now,
      shelf: finished ? Shelf.finished : Shelf.reading,
      finishedAt: finished ? now : null,
      clearFinished: !finished,
    );
    await _save(entry, previous: current);
    _markReadingDay();
  }

  Future<void> removeFromShelf(String bookId) async {
    final uid = _uid;
    final previous = _entries.remove(bookId);
    notifyListeners();
    if (uid == null || previous == null) return;
    try {
      await _shelfRepo.remove(uid, bookId);
    } catch (_) {
      _entries[bookId] = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setGoal(int goal) async {
    final uid = _uid;
    final old = _goal;
    _goal = goal.clamp(1, 365);
    notifyListeners();
    if (uid == null) return;
    try {
      await _profileRepo.saveReadingGoal(uid, _goal);
    } catch (_) {
      _goal = old;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _save(ShelfEntry entry, {ShelfEntry? previous}) async {
    final uid = _uid;
    _entries[entry.bookId] = entry;
    notifyListeners();
    if (uid == null) return;
    try {
      await _shelfRepo.save(uid, entry);
    } catch (_) {
      if (previous == null) {
        _entries.remove(entry.bookId);
      } else {
        _entries[entry.bookId] = previous;
      }
      notifyListeners();
      rethrow;
    }
  }

  void _markReadingDay() {
    final uid = _uid;
    if (uid == null) return;
    if (_readingDays.add(_key(DateTime.now()))) {
      _storage.writeReadingDays(uid, _readingDays);
      notifyListeners();
    }
  }

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---- Yaqinda ko'rilganlar ----

  List<String> get recentIds => List.unmodifiable(_recent);

  void markViewed(String bookId) {
    final uid = _uid;
    if (uid == null) return;
    if (_recent.isNotEmpty && _recent.first == bookId) return;
    _recent
      ..remove(bookId)
      ..insert(0, bookId);
    if (_recent.length > _maxRecent) _recent = _recent.sublist(0, _maxRecent);
    _storage.writeRecent(uid, _recent);
    notifyListeners();
  }
}
