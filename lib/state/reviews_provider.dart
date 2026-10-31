import 'package:flutter/foundation.dart';

import '../data/models/review.dart';
import '../data/repositories/store_repositories.dart';

/// Kitob sharhlari (kitob bo'yicha keshlanadi).
class ReviewsProvider extends ChangeNotifier {
  ReviewsProvider(this._repo);

  final ReviewRepository _repo;

  final Map<String, List<Review>> _cache = {};
  final Set<String> _loading = {};

  List<Review>? reviewsFor(String bookId) => _cache[bookId];
  bool isLoading(String bookId) => _loading.contains(bookId);

  double? averageFor(String bookId) {
    final list = _cache[bookId];
    if (list == null || list.isEmpty) return null;
    return list.fold(0.0, (s, r) => s + r.rating) / list.length;
  }

  Review? mine(String bookId, String? uid) {
    if (uid == null) return null;
    for (final r in _cache[bookId] ?? const <Review>[]) {
      if (r.userId == uid) return r;
    }
    return null;
  }

  Future<void> load(String bookId, {bool force = false}) async {
    if (_loading.contains(bookId)) return;
    if (_cache.containsKey(bookId) && !force) return;
    _loading.add(bookId);
    notifyListeners();
    try {
      _cache[bookId] = await _repo.fetch(bookId);
    } catch (_) {
      _cache[bookId] ??= [];
    } finally {
      _loading.remove(bookId);
      notifyListeners();
    }
  }

  Future<void> submit(String bookId, Review review) async {
    await _repo.save(bookId, review);
    final list = [...?_cache[bookId]]
      ..removeWhere((r) => r.userId == review.userId)
      ..insert(0, review);
    _cache[bookId] = list;
    notifyListeners();
  }
}
