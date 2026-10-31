import 'package:flutter/foundation.dart';

import '../data/repositories/store_repositories.dart';
import 'load_state.dart';

class WishlistProvider extends ChangeNotifier with LoadStateMixin {
  WishlistProvider(this._repo);

  final WishlistRepository _repo;

  String? _uid;
  Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);
  bool contains(String bookId) => _ids.contains(bookId);
  int get count => _ids.length;

  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _ids = {};
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
      _ids = await _repo.fetch(uid);
      status = LoadStatus.ready;
    } catch (e) {
      errorCode = LoadStateMixin.codeOf(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Optimistik almashtirish. Qaytaradi: endi sevimlimi.
  Future<bool> toggle(String bookId) async {
    final uid = _uid;
    if (uid == null) return false;
    final adding = !_ids.contains(bookId);
    _set(bookId, adding);
    try {
      if (adding) {
        await _repo.add(uid, bookId);
      } else {
        await _repo.remove(uid, bookId);
      }
    } catch (_) {
      _set(bookId, !adding);
      rethrow;
    }
    return adding;
  }

  void _set(String id, bool present) {
    if (present) {
      _ids.add(id);
    } else {
      _ids.remove(id);
    }
    notifyListeners();
  }
}
