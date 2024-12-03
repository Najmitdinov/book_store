import 'package:flutter/material.dart';

import '../models/categories.dart';

class Categories with ChangeNotifier {
  final List<CategoryItem> _list = [
    CategoryItem(id: 'c1', title: 'Popular books'),
    CategoryItem(id: 'c2', title: 'Lastest books'),
  ];

  List<CategoryItem> get list {
    return [..._list];
  }
}
