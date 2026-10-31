import 'package:flutter/material.dart';

import '../data/models/book.dart';
import '../features/admin/admin_orders_screen.dart';
import '../features/admin/edit_book_screen.dart';
import '../features/admin/manage_books_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/details/book_details_screen.dart';
import '../features/home/book_list_screen.dart';
import '../features/orders/orders_screen.dart';

class Routes {
  Routes._();

  static const details = '/details';
  static const cart = '/cart';
  static const orders = '/orders';
  static const bookList = '/books';
  static const manageBooks = '/admin/books';
  static const editBook = '/admin/edit-book';
  static const adminOrders = '/admin/orders';
}

class DetailsArgs {
  const DetailsArgs({required this.bookId, this.heroTag});
  final String bookId;
  final String? heroTag;
}

class BookListArgs {
  const BookListArgs({required this.title, required this.books});
  final String title;
  final List<Book> books;
}

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget page;
    switch (settings.name) {
      case Routes.details:
        final a = args is DetailsArgs
            ? args
            : DetailsArgs(bookId: args as String);
        page = BookDetailsScreen(bookId: a.bookId, heroTag: a.heroTag);
      case Routes.cart:
        page = const CartScreen();
      case Routes.orders:
        page = const OrdersScreen();
      case Routes.bookList:
        final list = args as BookListArgs;
        page = BookListScreen(title: list.title, books: list.books);
      case Routes.manageBooks:
        page = const ManageBooksScreen();
      case Routes.editBook:
        page = EditBookScreen(book: args as Book?);
      case Routes.adminOrders:
        page = const AdminOrdersScreen();
      default:
        return null;
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
