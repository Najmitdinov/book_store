import 'package:flutter/material.dart';

class CartItem with ChangeNotifier {
  final String id;
  final String title;
  final String imgUrl;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.price,
    required this.quantity,
  });
}
