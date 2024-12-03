import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/order.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_details.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const routeName = '/orders-screen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _future;

  Future getOrders() {
    return Provider.of<Order>(context, listen: false).getOrdersFromFirebase();
  }

  @override
  void initState() {
    _future = getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Buyurtmalar'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error == null) {
              return Consumer<Order>(
                builder: (ctx, orderData, child) {
                  return RefreshIndicator(
                    onRefresh: getOrders,
                    child: orderData.order.isNotEmpty
                        ? ListView.builder(
                            itemBuilder: (ctx, index) {
                              final order = orderData.order[index];
                              return ChangeNotifierProvider.value(
                                value: order,
                                child: const OrderDetails(),
                              );
                            },
                            itemCount: orderData.order.length,
                          )
                        : const Center(
                            child: Text(
                              'Buyurtmalar mavjud emas!',
                            ),
                          ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Xatolik sodir bo\'ldi'),
              );
            }
          }
        },
      ),
    );
  }
}
