import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/book.dart';
import '../providers/category.dart';

import '../models/books.dart';

import '../widgets/books_items.dart';
import '../widgets/another_books_item.dart';

class BooksDetails extends StatefulWidget {
  const BooksDetails({
    super.key,
  });

  @override
  State<BooksDetails> createState() => _BooksDetailsState();
}

class _BooksDetailsState extends State<BooksDetails> {
  bool isLoading = false;
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    try {
      Provider.of<Book>(context, listen: false).getBooksFromFireBase();
    } catch (error) {
      rethrow;
    }
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bookCategory = Provider.of<Categories>(context);
    final book = Provider.of<Book>(context);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : book.book.isNotEmpty
            ? Column(
                children: bookCategory.list.map(
                  (category) {
                    final bookList = book.book
                        .where((books) => books.categoryId == category.id)
                        .toList();
                    return category.id == 'c1'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: Text(
                                  category.title,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 280,
                                child: ListView.builder(
                                  itemBuilder: (ctx, index) {
                                    final bookItem = bookList[index];
                                    return ChangeNotifierProvider<Books>.value(
                                      value: bookItem,
                                      child: const BooksItems(),
                                    );
                                  },
                                  itemCount: bookList.length,
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  category.title,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  itemBuilder: (ctx, index) {
                                    return ChangeNotifierProvider<Books>.value(
                                      value: bookList[index],
                                      child: const AnotherBooksItem(),
                                    );
                                  },
                                  itemCount: bookList.length,
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),
                            ],
                          );
                  },
                ).toList(),
              )
            : const Center(
                child: Text(
                  'Mahsulotlar mavjud emas!',
                ),
              );
  }
}
