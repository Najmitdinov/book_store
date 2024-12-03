import 'package:flutter/material.dart';

import '../providers/book.dart';

import '../screens/details_screen.dart';

class CostumSeatchDelegate extends SearchDelegate {
  final Book bookData;
  CostumSeatchDelegate(this.bookData);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> searchItems = [];
    List<String> searchItemsId = [];

    for (var book in bookData.book) {
      if (book.title.toLowerCase().contains(query.toLowerCase())) {
        searchItems.add(book.title);
        searchItemsId.add(book.id);
      }
    }
    return ListView.builder(
      itemBuilder: (ctx, index) {
        var item = searchItems[index];
        return ListTile(
          onTap: () => Navigator.of(ctx).pushReplacementNamed(
            DetailsScreen.routeName,
            arguments: searchItemsId[index],
          ),
          title: Text(item),
        );
      },
      itemCount: searchItems.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> searchItems = [];
    List<String> searchItemsId = [];

    for (var book in bookData.book) {
      if (book.title.toLowerCase().contains(query.toLowerCase())) {
        searchItems.add(book.title);
        searchItemsId.add(book.id);
      }
    }
    return ListView.builder(
      itemBuilder: (ctx, index) {
        var item = searchItems[index];
        return ListTile(
          onTap: () => Navigator.of(ctx).pushReplacementNamed(
            DetailsScreen.routeName,
            arguments: searchItemsId[index],
          ),
          title: Text(item),
        );
      },
      itemCount: searchItems.length,
    );
  }
}
