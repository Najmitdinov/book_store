import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/cart_item.dart';

import '../providers/cart.dart';

class CartDetails extends StatelessWidget {
  final String id;
  final String title;
  final String imgUrl;
  final double price;
  const CartDetails({
    super.key,
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final cart = Provider.of<CartItem>(context);
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.3,
        motion: const ScrollMotion(),
        children: [
          Container(
            height: 70,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                cartData.deleteFromCart(id);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      child: Card(
        child: ListTile(
          leading: Image.network(
            cart.imgUrl,
          ),
          title: Text(
            cart.title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('\$${cart.price.toStringAsFixed(2)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  cartData.removeToCart(
                    id,
                    title,
                    imgUrl,
                    price,
                  );
                },
                icon: const Icon(
                  Icons.remove,
                  color: Colors.black,
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                child: Text(
                  cart.quantity.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  cartData.addToCart(
                    id,
                    cart.title,
                    cart.imgUrl,
                    cart.price,
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
