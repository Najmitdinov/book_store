import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/book.dart';

import '../screens/add_new_book_screen.dart';

import '../widgets/app_drawer.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  static const routeName = 'manage-books';

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  Future<void> getBooks() async {
    await Provider.of<Book>(context, listen: false).getBooksFromFireBase(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Kitoblar'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AddNewBookScreen.routeName),
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getBooks(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error == null) {
              return Consumer<Book>(
                builder: (ctx, bookData, _) {
                  return RefreshIndicator(
                    onRefresh: getBooks,
                    child: bookData.book.isNotEmpty
                        ? ListView.builder(
                            itemBuilder: (ctx, index) {
                              final book = bookData.book[index];
                              return ListTile(
                                leading: Image.network(
                                  book.imgUrl,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  book.title,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Text(
                                  book.discout < 1
                                      ? '\$${book.price.toStringAsFixed(2)}'
                                      : '\$${bookData.calculatedDiscount(book.id).toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          AddNewBookScreen.routeName,
                                          arguments: book.id,
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        try {
                                          await showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                content: const Text(
                                                  'Mahsulot o\'chirilmoqda!',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop(),
                                                    child: const Text(
                                                      'BEKOR QILIS',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      bookData
                                                          .deleteBook(book.id);
                                                      Navigator.of(ctx).pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text(
                                                      'O\'CHIRISH',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } catch (error) {
                                          rethrow;
                                        }
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: bookData.book.length,
                          )
                        : const Center(
                            child: Text(
                              'Mahsulotlar mavjud emas!',
                            ),
                          ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Xalolik sodir bo\'di'),
              );
            }
          }
        },
      ),
    );
  }
}
