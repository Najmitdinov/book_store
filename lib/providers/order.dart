import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cart_item.dart';
import '../models/order_item.dart';

class Order with ChangeNotifier {
  List<OrderItem> _order = [];

  String? _authToken;
  String? _userId;

  void setParams(String? authToken, String? userId) {
    _authToken = authToken;
    _userId = userId;
  }

  Future<void> addToOrder(double totalPrice, List<CartItem> cart) async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken');
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'date': DateTime.now().toIso8601String(),
            'totalPrice': totalPrice,
            'products': cart
                .map(
                  (cartProdcuts) => {
                    'id': cartProdcuts.id,
                    'title': cartProdcuts.title,
                    'price': cartProdcuts.price,
                    'imgUrl': cartProdcuts.imgUrl,
                    'quantity': cartProdcuts.quantity,
                  },
                )
                .toList()
          },
        ),
      );
      final orederId = jsonDecode(response.body)['name'];
      _order.add(
        OrderItem(
          id: orederId,
          date: DateTime.now(),
          totalPrice: totalPrice,
          products: cart,
        ),
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getOrdersFromFirebase() async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken');

    try {
      final response = await http.get(url);
      if (jsonDecode(response.body) == null) {
        return;
      }
      final List<OrderItem> _uploadedOrder = [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      data.forEach(
        (id, cart) {
          _uploadedOrder.insert(
            0,
            OrderItem(
              id: id,
              date: DateTime.parse(cart['date']),
              totalPrice: cart['totalPrice'],
              products: (cart['products'] as List<dynamic>)
                  .map(
                    (cartPro) => CartItem(
                      id: cartPro['id'],
                      title: cartPro['title'],
                      imgUrl: cartPro['imgUrl'],
                      price: cartPro['price'],
                      quantity: cartPro['quantity'],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      );
      _order = _uploadedOrder;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<OrderItem> get order {
    return [..._order];
  }
}
