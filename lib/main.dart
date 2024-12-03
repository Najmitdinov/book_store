import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/book.dart';
import '../providers/cart.dart';
import '../providers/category.dart';
import '../providers/order.dart';

import '../screens/add_new_book_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/control_screens.dart';
import '../screens/details_screen.dart';
import '../screens/manage_books_screen.dart';
import '../screens/orders_screen.dart';

import '../styles/book_store_style.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData theme = BookStoreStyle().style;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Categories>(
          create: (ctx) => Categories(),
        ),
        ChangeNotifierProvider<Auth>(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Book>(
          create: (ctx) => Book(),
          update: (context, auth, previousBook) =>
              previousBook!..setParams(auth.token, auth.userId),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (ctx) => Order(),
          update: (context, auth, previousOrder) =>
              previousOrder!..setParams(auth.token, auth.userId),
        ),
        ChangeNotifierProvider<Cart>(
          create: (ctx) => Cart(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: auth.isAuth
                ? const ControlScreens()
                : FutureBuilder(
                    future: auth.autoLogIn(),
                    builder: (ctx, dataSnapShot) {
                      if (dataSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return const AuthScreen();
                      }
                    },
                  ),
            routes: {
              ControlScreens.routeName: (ctx) => const ControlScreens(),
              DetailsScreen.routeName: (ctx) => const DetailsScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              ManageBooksScreen.routeName: (ctx) => const ManageBooksScreen(),
              AddNewBookScreen.routeName: (ctx) => const AddNewBookScreen(),
            },
          );
        },
      ),
    );
  }
}
