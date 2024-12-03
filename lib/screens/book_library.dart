import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/book.dart';

import '../widgets/app_drawer.dart';

class BookLibrary extends StatefulWidget {
  const BookLibrary({super.key});

  @override
  State<BookLibrary> createState() => _BookLibraryState();
}

class _BookLibraryState extends State<BookLibrary> {
  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      Provider.of<Book>(context, listen: false).getWishedBooksFromFireBase();
    }
    init = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bookData = Provider.of<Book>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Library'),
        centerTitle: true,
      ),
      body: bookData.wishedList.isNotEmpty
          ? GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 4 / 7,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (ctx, index) {
                final book = bookData.wishedList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        book.imgUrl,
                        fit: BoxFit.cover,
                        height: 280,
                        width: double.infinity,
                      ),
                    ),
                    Text(book.title),
                  ],
                );
              },
              itemCount: bookData.wishedList.length,
            )
          : const Center(
              child: Text(
                'Istakral sahifasida kitoblar mavjud emas',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
    );
  }
}
