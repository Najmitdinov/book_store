import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';

import '../screens/cart_screen.dart';
import '../screens/control_screens.dart';
import '../screens/manage_books_screen.dart';
import '../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authEmail = Provider.of<Auth>(context);
    return Drawer(
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            margin: const EdgeInsets.all(0),
            accountName: const Text('Umar Najmitdinov'),
            accountEmail: Text(authEmail.email.toString()),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://media.istockphoto.com/id/1476170969/photo/portrait-of-young-man-ready-for-job-business-concept.webp?a=1&b=1&s=612x612&w=0&k=20&c=-F_sZl6saA5wNg2OTdO3zcHZ3aQ2ml9Ru-PXGcUDdHg=',
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
          ListTile(
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(ControlScreens.routeName),
            leading: const Icon(Icons.home),
            title: const Text('Bosh sahifa'),
          ),
          ListTile(
            onTap: () =>
                Navigator.of(context).popAndPushNamed(CartScreen.routeName),
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Savatcha sahifa'),
          ),
          ListTile(
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(OrdersScreen.routeName),
            leading: const Icon(Icons.payment),
            title: const Text('Buyurtmalar sahifa'),
          ),
          ListTile(
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(ManageBooksScreen.routeName),
            leading: const Icon(Icons.panorama_wide_angle_select_rounded),
            title: const Text('Barcha kitoblar sahifasi'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pop();
              Provider.of<Auth>(context, listen: false).logOut();
            },
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }
}
