import 'dart:math';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order_item.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final order = Provider.of<OrderItem>(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Mahsulot kodi: ${order.date.microsecond}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            subtitle: Text(
              DateFormat('d/MMM/yyyy hh:mm').format(order.date),
            ),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_sharp
                    : Icons.keyboard_arrow_down_sharp,
              ),
            ),
          ),
          if (isExpanded)
            SizedBox(
              height: min(order.products.length * 70 + 10, 150),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 10),
                itemBuilder: (ctx, index) {
                  final cartOrder = order.products[index];
                  return ListTile(
                    leading: Image.network(
                      cartOrder.imgUrl,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      cartOrder.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '\$${cartOrder.price.toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      'x${cartOrder.quantity}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
                itemCount: order.products.length,
              ),
            )
        ],
      ),
    );
  }
}
