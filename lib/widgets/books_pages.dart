import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/books.dart';

import '../providers/book.dart';
import '../providers/cart.dart';

class BooksPages extends StatelessWidget {
  const BooksPages({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final book = Provider.of<Books>(context);
    final bookData = Provider.of<Book>(context);
    final cartData = Provider.of<Cart>(context);
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(4),
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                book.bgColor,
                book.bgColor,
                book.bgColor,
                Colors.black87,
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              fit: BoxFit.contain,
              book.imgUrl,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              
              children: [
                Text(
                  book.discout > 1
                      ? '\$${bookData.calculatedDiscount(book.id).toStringAsFixed(2)}'
                      : '\$${book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  book.discout > 1 ? '\$${book.price}' : '',
                  style:  TextStyle(
                    color: Colors.grey.shade800,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.only(right: 15),
          alignment: Alignment.center,
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
          child: IconButton(
            onPressed: () {
              cartData.addToCart(
                book.id,
                book.title,
                book.imgUrl,
                book.discout < 1
                    ? book.price
                    : bookData.calculatedDiscount(book.id),
              );
            },
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
