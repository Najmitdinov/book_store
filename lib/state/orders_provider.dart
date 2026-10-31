import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/order.dart';
import '../data/repositories/store_repositories.dart';
import 'load_state.dart';

class OrdersProvider extends ChangeNotifier with LoadStateMixin {
  OrdersProvider(this._repo);

  final OrderRepository _repo;

  String? _uid;
  List<Order> _orders = [];

  // Admin uchun
  List<Order> _allOrders = [];
  LoadStatus allStatus = LoadStatus.idle;

  List<Order> get orders => List.unmodifiable(_orders);
  List<Order> get allOrders => List.unmodifiable(_allOrders);

  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _orders = [];
    _allOrders = [];
    status = LoadStatus.idle;
    allStatus = LoadStatus.idle;
    Future.microtask(notifyListeners);
  }

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    status = LoadStatus.loading;
    errorCode = null;
    notifyListeners();
    try {
      _orders = await _repo.fetchMine(uid);
      status = LoadStatus.ready;
    } catch (e) {
      errorCode = LoadStateMixin.codeOf(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<Order> place({
    required List<CartItem> items,
    required double total,
    required double discountAmount,
    String? promoCode,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('No user');
    final draft = Order(
      id: '',
      userId: uid,
      date: DateTime.now(),
      totalPrice: double.parse(total.toStringAsFixed(2)),
      discountAmount: double.parse(discountAmount.toStringAsFixed(2)),
      promoCode: promoCode,
      products: items,
    );
    final id = await _repo.create(uid, draft);
    final order = Order(
      id: id,
      userId: uid,
      date: draft.date,
      totalPrice: draft.totalPrice,
      discountAmount: draft.discountAmount,
      promoCode: promoCode,
      products: items,
    );
    _orders = [order, ..._orders];
    notifyListeners();
    return order;
  }

  Future<void> loadAll() async {
    allStatus = LoadStatus.loading;
    notifyListeners();
    try {
      _allOrders = await _repo.fetchAll();
      allStatus = LoadStatus.ready;
    } catch (e) {
      errorCode = LoadStateMixin.codeOf(e);
      allStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> updateStatus(Order order, OrderStatus newStatus) async {
    await _repo.updateStatus(order, newStatus);
    Order patch(Order o) =>
        (o.id == order.id && o.userId == order.userId)
            ? o.copyWith(status: newStatus)
            : o;
    _allOrders = _allOrders.map(patch).toList();
    _orders = _orders.map(patch).toList();
    notifyListeners();
  }
}
