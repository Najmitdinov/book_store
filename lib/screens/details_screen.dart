import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import '../providers/book.dart';
import '../providers/cart.dart';

import '../screens/cart_screen.dart';

import '../widgets/book_sliver_app.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  static const routeName = '/details-screen';

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  double _dragPosition = 0;
  final double _dragThreshold = 250;

  @override
  Widget build(BuildContext context) {
    final bookData = Provider.of<Book>(context);
    final cartData = Provider.of<Cart>(context);
    final bookId = ModalRoute.of(context)!.settings.arguments as String;

    final book = bookData.book.firstWhere((product) => product.id == bookId);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) {
          return [
            BookSliverApp(book),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'From the publisher',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              Text(
                book.description,
              ),
              const SizedBox(
                height: 10,
              ),
              // Text(
              //   '${book.discout.toString()}% discount',
              //   style: const TextStyle(
              //     color: Colors.black,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const Text('More Books'),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    final optionBooks = bookData.book[index];
                    return SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            optionBooks.imgUrl,
                            height: 100,
                            width: 100,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              optionBooks.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: bookData.book.length,
                  scrollDirection: Axis.horizontal,
                ),
              ),
              const Divider(),
              const Text('More Books'),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    final optionBooks = bookData.book[index];
                    return SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            optionBooks.imgUrl,
                            height: 100,
                            width: 100,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              optionBooks.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: bookData.book.length,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: BottomAppBar(
        height: 110,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Narxi:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  book.discout < 1
                      ? '\$${book.price.toStringAsFixed(2)}'
                      : '\$${bookData.calculatedDiscount(book.id).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            !cartData.cart.containsKey(book.id)
                ? Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Savatchaga qo\'shish',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // The draggable button
                      GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            // Update the drag position
                            _dragPosition += details.delta.dx;
                            _dragPosition = _dragPosition.clamp(0.0, 330.0);
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          if (_dragPosition >= _dragThreshold) {
                            cartData.addToCart(
                              book.id,
                              book.title,
                              book.imgUrl,
                              book.discout < 1
                                  ? book.price
                                  : bookData.calculatedDiscount(book.id),
                            );
                            setState(() {
                              _dragPosition = 0;
                            });
                          } else {
                            setState(() {
                              _dragPosition = 0;
                            });
                          }
                        },
                        child: Transform.translate(
                          offset: Offset(_dragPosition + 5, 0),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_cart_checkout,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed(CartScreen.routeName),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Savatchaga borish',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
