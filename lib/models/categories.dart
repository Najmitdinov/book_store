import 'package:flutter/material.dart';

class CategoryItem with ChangeNotifier{
  String id;
  String title;

  CategoryItem({
    required this.id,
    required this.title,
  });
}
