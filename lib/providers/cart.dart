import 'package:flutter/material.dart';

import '../models/cart_item.dart';

class Cart with ChangeNotifier {
  final Map<String, CartItem> _cart = {};

  void addToCart(
    String id,
    String title,
    String imgUrl,
    double price,
  ) {
    if (_cart.containsKey(id)) {
      _cart.update(
        id,
        (currentBookDetaild) {
          return CartItem(
            id: currentBookDetaild.id,
            title: currentBookDetaild.title,
            imgUrl: currentBookDetaild.imgUrl,
            price: currentBookDetaild.price,
            quantity: currentBookDetaild.quantity + 1,
          );
        },
      );
    } else if (!_cart.containsKey(id)) {
      _cart.putIfAbsent(id, () {
        return CartItem(
          id: id,
          title: title,
          imgUrl: imgUrl,
          price: price,
          quantity: 1,
        );
      });
    }
    notifyListeners();
  }

  void removeToCart(
    String id,
    String title,
    String imgUrl,
    double price,
  ) {
    if (_cart[id]!.quantity <= 1) {
      return;
    }
    if (_cart.containsKey(id)) {
      _cart.update(
        id,
        (currentBookDetaild) {
          return CartItem(
            id: currentBookDetaild.id,
            title: currentBookDetaild.title,
            imgUrl: currentBookDetaild.imgUrl,
            price: currentBookDetaild.price,
            quantity: currentBookDetaild.quantity - 1,
          );
        },
      );
    }
    notifyListeners();
  }

  double totalPrice() {
    double totalSum = 0.0;
    _cart.forEach((key, cart) {
      totalSum += cart.price * cart.quantity;
    });
    return totalSum;
  }

  void deleteFromCart(String id) {
    _cart.remove(id);
    notifyListeners();
  }

  int cartLenght() {
    return _cart.length;
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Map<String, CartItem> get cart {
    return {..._cart};
  }
}
