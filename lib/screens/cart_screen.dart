import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/book.dart';
import '../providers/cart.dart';
import '../providers/order.dart';

import '../screens/orders_screen.dart';

import '../widgets/cart_details.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static const routeName = '/cart-screen';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _dragPosition = 0;
  final double _dragThreshold = 250;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bookData = Provider.of<Book>(context);
    final cartData = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.white,
        title: const Text('Savatcha'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: cartData.clearCart,
            child: const Text(
              'Tozalash',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: cartData.cart.isNotEmpty
          ? Column(
              children: [
                const Text(
                  'Sizning savatchadagi mahsulotlaringiz!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      final cartBook = cartData.cart.values.toList()[index];
                      final book = bookData.book[index];
                      return ChangeNotifierProvider.value(
                        value: cartBook,
                        child: CartDetails(
                          id: cartData.cart.keys.toList()[index],
                          title: book.title,
                          imgUrl: book.imgUrl,
                          price: book.discout < 1
                              ? book.price
                              : bookData.calculatedDiscount(book.id),
                        ),
                      );
                    },
                    itemCount: cartData.cart.length,
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                'Savatchada xozircha mahsulotlar mavjud emas!',
              ),
            ),
      bottomSheet: BottomAppBar(
        height: 100,
        color: Colors.white,
        shadowColor: Colors.black,
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Umumiy narxi: \$${cartData.totalPrice().toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            cartData.cart.isNotEmpty
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
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Buyurtma berish',
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
                        onHorizontalDragEnd: (details) async {
                          if (_dragPosition >= _dragThreshold) {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              await Provider.of<Order>(context, listen: false)
                                  .addToOrder(
                                cartData.totalPrice(),
                                cartData.cart.values.toList(),
                              );

                              cartData.clearCart();
                            } catch (error) {
                              rethrow;
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }

                            setState(() {
                              _dragPosition = 0;
                            });
                          } else {
                            setState(() {
                              _dragPosition = 0;
                            });
                          }
                        },
                        child: isLoading
                            ? Container()
                            : Transform.translate(
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
                                      Icons.account_balance_wallet,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () => Navigator.of(context)
                        .pushReplacementNamed(OrdersScreen.routeName),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Buyurtmalar sahifasiga borish',
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
