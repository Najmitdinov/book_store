import 'package:flutter/foundation.dart';

import 'cart_item.dart';
import 'json_utils.dart';

enum OrderStatus {
  newOrder('new', 'status_new'),
  processing('processing', 'status_processing'),
  shipped('shipped', 'status_shipped'),
  delivered('delivered', 'status_delivered'),
  cancelled('cancelled', 'status_cancelled');

  const OrderStatus(this.value, this.labelKey);

  final String value;
  final String labelKey;

  static OrderStatus parse(dynamic v) => OrderStatus.values.firstWhere(
        (s) => s.value == v,
        orElse: () => OrderStatus.newOrder,
      );

  /// Vaqt chizig'idagi bosqichlar (bekor qilinganidan tashqari).
  static const flow = [newOrder, processing, shipped, delivered];
}

@immutable
class Order {
  final String id;
  final String userId;
  final DateTime date;
  final double totalPrice;
  final double discountAmount;
  final String? promoCode;
  final List<CartItem> products;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalPrice,
    required this.products,
    this.discountAmount = 0,
    this.promoCode,
    this.status = OrderStatus.newOrder,
  });

  int get itemsCount => products.fold(0, (sum, p) => sum + p.quantity);

  /// Foydalanuvchiga ko'rsatiladigan qisqa raqam.
  String get shortId =>
      id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id;

  factory Order.fromJson(String id, String userId, Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final list = rawProducts is List
        ? rawProducts
        : (rawProducts is Map ? rawProducts.values.toList() : const []);
    return Order(
      id: id,
      userId: userId,
      date: asDate(json['date']),
      totalPrice: asDouble(json['totalPrice']),
      discountAmount: asDouble(json['discountAmount']),
      promoCode: json['promoCode']?.toString(),
      status: OrderStatus.parse(json['status']),
      products: list
          .where((e) => e != null)
          .map((e) => CartItem.fromJson(asMap(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'totalPrice': totalPrice,
        'discountAmount': discountAmount,
        if (promoCode != null) 'promoCode': promoCode,
        'status': status.value,
        'products': products.map((p) => p.toJson()).toList(),
      };

  Order copyWith({OrderStatus? status}) => Order(
        id: id,
        userId: userId,
        date: date,
        totalPrice: totalPrice,
        products: products,
        discountAmount: discountAmount,
        promoCode: promoCode,
        status: status ?? this.status,
      );
}
