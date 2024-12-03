import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/book.dart';
import '../providers/cart.dart';
import '../providers/category.dart';

import '../models/books.dart';

import '../screens/cart_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/books_pages.dart';
import '../widgets/costume_search_bar.dart';

class BookCategories extends StatelessWidget {
  const BookCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<Categories>(context);
    final bookData = Provider.of<Book>(context);
    final cartData = Provider.of<Cart>(context);

    return DefaultTabController(
      length: categories.list.length,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CostumSeatchDelegate(bookData),
                );
              },
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.black,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(CartScreen.routeName),
                  icon: const Icon(
                    Icons.shopping_bag,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  top: 3,
                  right: 5,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    height: 20,
                    width: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Text(cartData.cartLenght().toString()),
                  ),
                ),
              ],
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 60),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                automaticIndicatorColorAdjustment: true,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Colors.black,
                labelColor: Colors.white,
                tabs: categories.list.map((category) {
                  return Tab(
                    child: Text(category.title),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: categories.list.map(
            (category) {
              final books = bookData.book
                  .where((book) => book.categoryId == category.id)
                  .toList();
              return books.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (ctx, index) {
                        final book = books[index];
                        return ChangeNotifierProvider<Books>.value(
                          value: book,
                          child: const BooksPages(),
                        );
                      },
                      itemCount: books.length,
                    )
                  : const Center(
                      child: Text(
                        'Kitoblar hozircha mavjud emas!',
                      ),
                    );
            },
          ).toList(),
        ),
      ),
    );
  }
}
