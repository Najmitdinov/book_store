import 'package:flutter/material.dart';

import '../../core/widgets/book_card.dart';
import '../../data/models/book.dart';
import '../shell/main_shell.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key, required this.title, required this.books});

  final String title;
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [CartButton()],
      ),
      body: BookGrid(books: books, heroPrefix: 'list'),
    );
  }
}

/// Ekran kengligiga moslashuvchi kitoblar to'ri.
class BookGrid extends StatelessWidget {
  const BookGrid({
    super.key,
    required this.books,
    required this.heroPrefix,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 32),
  });

  final List<Book> books;
  final String heroPrefix;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisExtent: 330,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: books.length,
      itemBuilder: (_, i) => LayoutBuilder(
        builder: (_, c) => BookCard(
          book: books[i],
          width: c.maxWidth,
          heroPrefix: heroPrefix,
        ),
      ),
    );
  }
}
