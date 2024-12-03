import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/books.dart';

import '../providers/book.dart';

import '../screens/details_screen.dart';

class AnotherBooksItem extends StatelessWidget {
  const AnotherBooksItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final book = Provider.of<Books>(context);
    final bookData = Provider.of<Book>(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          DetailsScreen.routeName,
          arguments: book.id,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                      ),
                      color: book.bgColor,
                    ),
                  ),
                ),
                Container(
                  width: 70,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      book.imgUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              book.discout <= 0
                  ? '\$${book.price.toStringAsFixed(2)}'
                  : '\$${bookData.calculatedDiscount(book.id).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
