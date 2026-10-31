import 'package:flutter/foundation.dart';

import '../data/local/local_storage.dart';
import '../data/models/book.dart';
import '../data/models/cart_item.dart';
import '../data/repositories/store_repositories.dart';

/// Savatcha: qurilmada foydalanuvchi bo'yicha saqlanadi, ilova
/// yopilsa ham yo'qolmaydi.
class CartProvider extends ChangeNotifier {
  CartProvider(this._storage, this._promoRepo);

  final LocalStorage _storage;
  final PromoRepository _promoRepo;

  String? _uid;
  final Map<String, CartItem> _items = {};
  String? _promoCode;
  int _promoPercent = 0;

  static const maxQuantity = 20;

  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _items.clear();
    _promoCode = null;
    _promoPercent = 0;
    if (uid != null) {
      for (final json in _storage.readCart(uid)) {
        final item = CartItem.fromJson(json);
        if (item.id.isNotEmpty) _items[item.id] = item;
      }
    }
    Future.microtask(notifyListeners);
  }

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get count => _items.values.fold(0, (s, i) => s + i.quantity);
  bool contains(String bookId) => _items.containsKey(bookId);
  int quantityOf(String bookId) => _items[bookId]?.quantity ?? 0;

  String? get promoCode => _promoCode;
  int get promoPercent => _promoPercent;

  /// Chegirmasiz summa.
  double get originalSubtotal =>
      _items.values.fold(0.0, (s, i) => s + i.originalTotal);

  /// Kitob chegirmalari qo'llangan summa.
  double get subtotal => _items.values.fold(0.0, (s, i) => s + i.total);

  double get bookSavings => originalSubtotal - subtotal;

  double get promoDiscount => subtotal * _promoPercent / 100;

  double get total => (subtotal - promoDiscount).clamp(0.0, double.infinity);

  void add(Book book) {
    final existing = _items[book.id];
    _items[book.id] = existing == null
        ? CartItem.fromBook(book)
        : existing.copyWith(
            quantity: (existing.quantity + 1).clamp(1, maxQuantity),
          );
    _changed();
  }

  void increment(String id) {
    final item = _items[id];
    if (item == null || item.quantity >= maxQuantity) return;
    _items[id] = item.copyWith(quantity: item.quantity + 1);
    _changed();
  }

  void decrement(String id) {
    final item = _items[id];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(id);
    } else {
      _items[id] = item.copyWith(quantity: item.quantity - 1);
    }
    _changed();
  }

  /// O'chirilgan pozitsiyani qaytaradi ("Bekor qilish" uchun).
  CartItem? remove(String id) {
    final removed = _items.remove(id);
    _changed();
    return removed;
  }

  void restore(CartItem item) {
    _items[item.id] = item;
    _changed();
  }

  void clear() {
    _items.clear();
    _promoCode = null;
    _promoPercent = 0;
    _changed();
  }

  /// `true` — kod qabul qilindi.
  Future<bool> applyPromo(String code) async {
    final percent = await _promoRepo.check(code);
    if (percent == null) return false;
    _promoCode = code.trim().toUpperCase();
    _promoPercent = percent;
    notifyListeners();
    return true;
  }

  void removePromo() {
    _promoCode = null;
    _promoPercent = 0;
    notifyListeners();
  }

  void _changed() {
    notifyListeners();
    final uid = _uid;
    if (uid != null) {
      _storage.writeCart(uid, _items.values.map((e) => e.toJson()).toList());
    }
  }
}
