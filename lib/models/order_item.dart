import 'package:flutter/material.dart';

import '../models/cart_item.dart';

class OrderItem with ChangeNotifier{
  final String id;
  final DateTime date;
  final double totalPrice;
  final List<CartItem> products;

  OrderItem({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.products,
  });
}
