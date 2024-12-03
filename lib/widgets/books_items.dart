import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/books.dart';

import '../providers/book.dart';

import '../screens/details_screen.dart';

class BooksItems extends StatelessWidget {
  const BooksItems({super.key});

  @override
  Widget build(BuildContext context) {
    final book = Provider.of<Books>(context);
    final bookData = Provider.of<Book>(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                DetailsScreen.routeName,
                arguments: book.id,
              ),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    width: 120,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: book.bgColor,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    padding: const EdgeInsets.all(25),
                    width: 120,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          spreadRadius: -2,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        book.imgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                book.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.discout > 0
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
                if (book.discout > 1)
                  Text(
                    '\$${book.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
