import 'package:flutter/foundation.dart';

import 'book.dart';
import 'json_utils.dart';

/// Savatdagi bitta pozitsiya. [price] — chegirma qo'llangan yakuniy narx,
/// [originalPrice] — chegirmasiz narx (tejalgan summani ko'rsatish uchun).
@immutable
class CartItem {
  final String id;
  final String title;
  final String author;
  final String imgUrl;
  final double price;
  final double originalPrice;
  final int quantity;

  const CartItem({
    required this.id,
    required this.title,
    required this.author,
    required this.imgUrl,
    required this.price,
    required this.originalPrice,
    required this.quantity,
  });

  factory CartItem.fromBook(Book book, {int quantity = 1}) => CartItem(
        id: book.id,
        title: book.title,
        author: book.author,
        imgUrl: book.imgUrl,
        price: book.finalPrice,
        originalPrice: book.price,
        quantity: quantity,
      );

  double get total => price * quantity;
  double get originalTotal => originalPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        title: title,
        author: author,
        imgUrl: imgUrl,
        price: price,
        originalPrice: originalPrice,
        quantity: quantity ?? this.quantity,
      );

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final price = asDouble(json['price']);
    return CartItem(
      id: asString(json['id']),
      title: asString(json['title'], '—'),
      author: asString(json['author']),
      imgUrl: asString(json['imgUrl']),
      price: price,
      originalPrice: asDouble(json['originalPrice'], price),
      quantity: asInt(json['quantity'], 1),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'imgUrl': imgUrl,
        'price': price,
        'originalPrice': originalPrice,
        'quantity': quantity,
      };
}
