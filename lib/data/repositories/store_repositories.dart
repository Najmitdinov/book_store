import '../../core/network/api_client.dart';
import '../models/book.dart';
import '../models/json_utils.dart';
import '../models/order.dart';
import '../models/review.dart';
import '../models/shelf_entry.dart';
import '../models/user_profile.dart';

/// Firebase Realtime Database tuzilmasi:
///
/// ```
/// books/{bookId}                 — kitoblar katalogi (faqat admin yozadi)
/// admins/{uid}: true             — admin foydalanuvchilar
/// users/{uid}                    — profil: name, email, avatarColor, readingGoal
/// wishList/{uid}/{bookId}        — sevimlilar
/// shelves/{uid}/{bookId}         — shaxsiy javon va o'qish jarayoni
/// orders/{uid}/{orderId}         — buyurtmalar
/// reviews/{bookId}/{uid}         — sharhlar (har foydalanuvchidan bittadan)
/// promoCodes/{CODE}: percent     — promo-kodlar
/// ```

class BookRepository {
  BookRepository(this._api);
  final ApiClient _api;

  Future<List<Book>> fetchAll() async {
    final data = await _api.get('books');
    if (data is! Map) return [];
    final books = <Book>[];
    asMap(data).forEach((id, value) {
      if (value is Map) books.add(Book.fromJson(id, asMap(value)));
    });
    return books;
  }

  Future<String> create(Book book) => _api.post('books', book.toJson());

  Future<void> update(Book book) => _api.patch('books/${book.id}', book.toJson());

  Future<void> delete(String id) => _api.delete('books/$id');
}

class WishlistRepository {
  WishlistRepository(this._api);
  final ApiClient _api;

  /// Kalitlar — kitob ID'lari (eski versiya formatiga ham mos).
  Future<Set<String>> fetch(String uid) async {
    final data = await _api.get('wishList/$uid');
    if (data is! Map) return {};
    return asMap(data).keys.toSet();
  }

  Future<void> add(String uid, String bookId) => _api.put(
        'wishList/$uid/$bookId',
        {'addedAt': DateTime.now().toIso8601String()},
      );

  Future<void> remove(String uid, String bookId) =>
      _api.delete('wishList/$uid/$bookId');
}

class OrderRepository {
  OrderRepository(this._api);
  final ApiClient _api;

  Future<List<Order>> fetchMine(String uid) async {
    final data = await _api.get('orders/$uid');
    return _parseUserOrders(uid, data);
  }

  /// Faqat admin uchun: barcha foydalanuvchilar buyurtmalari.
  Future<List<Order>> fetchAll() async {
    final data = await _api.get('orders');
    if (data is! Map) return [];
    final all = <Order>[];
    asMap(data).forEach((uid, orders) {
      all.addAll(_parseUserOrders(uid, orders));
    });
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  Future<String> create(String uid, Order order) =>
      _api.post('orders/$uid', order.toJson());

  Future<void> updateStatus(Order order, OrderStatus status) => _api.patch(
        'orders/${order.userId}/${order.id}',
        {'status': status.value},
      );

  List<Order> _parseUserOrders(String uid, dynamic data) {
    if (data is! Map) return [];
    final list = <Order>[];
    asMap(data).forEach((id, value) {
      if (value is Map) list.add(Order.fromJson(id, uid, asMap(value)));
    });
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}

class ProfileRepository {
  ProfileRepository(this._api);
  final ApiClient _api;

  Future<UserProfile> fetch(String uid, String email) async {
    final results = await Future.wait([
      _api.get('users/$uid'),
      _isAdmin(uid),
    ]);
    return UserProfile.fromJson(
      uid,
      email,
      asMap(results[0]),
      isAdmin: results[1] == true,
    );
  }

  Future<bool> _isAdmin(String uid) async {
    try {
      return await _api.get('admins/$uid') == true;
    } catch (_) {
      // Qoidalar o'qishga ruxsat bermasa — oddiy foydalanuvchi.
      return false;
    }
  }

  Future<void> save(UserProfile profile) =>
      _api.patch('users/${profile.uid}', profile.toJson());

  Future<int?> fetchReadingGoal(String uid) async {
    final v = await _api.get('users/$uid/readingGoal');
    return v == null ? null : asInt(v);
  }

  Future<void> saveReadingGoal(String uid, int goal) =>
      _api.put('users/$uid/readingGoal', goal);
}

class ShelfRepository {
  ShelfRepository(this._api);
  final ApiClient _api;

  Future<Map<String, ShelfEntry>> fetch(String uid) async {
    final data = await _api.get('shelves/$uid');
    if (data is! Map) return {};
    return asMap(data).map(
      (id, v) => MapEntry(id, ShelfEntry.fromJson(id, asMap(v))),
    );
  }

  Future<void> save(String uid, ShelfEntry entry) =>
      _api.put('shelves/$uid/${entry.bookId}', entry.toJson());

  Future<void> remove(String uid, String bookId) =>
      _api.delete('shelves/$uid/$bookId');
}

class ReviewRepository {
  ReviewRepository(this._api);
  final ApiClient _api;

  Future<List<Review>> fetch(String bookId) async {
    final data = await _api.get('reviews/$bookId');
    if (data is! Map) return [];
    final list = asMap(data)
        .entries
        .where((e) => e.value is Map)
        .map((e) => Review.fromJson(e.key, asMap(e.value)))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> save(String bookId, Review review) =>
      _api.put('reviews/$bookId/${review.userId}', review.toJson());
}

class PromoRepository {
  PromoRepository(this._api);
  final ApiClient _api;

  /// Firebase'da hali promo-kod bo'lmasa ham ilova ishlashi uchun
  /// standart kodlar.
  static const _builtIn = {'KITOBXON10': 10, 'BOOKLOVER': 15};

  /// Chegirma foizini qaytaradi yoki kod topilmasa `null`.
  Future<int?> check(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    try {
      final v = await _api.get('promoCodes/$normalized');
      if (v != null) {
        final p = asInt(v);
        if (p > 0 && p <= 90) return p;
      }
    } catch (_) {
      // Tarmoq xatosida mahalliy kodlarga tayanamiz.
    }
    return _builtIn[normalized];
  }
}
