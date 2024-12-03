import 'package:flutter/material.dart';

class Books with ChangeNotifier {
  final String id;
  final String title;
  final String author;
  final String ganre;
  DateTime date;
  final List<String> language;
  final int pageLength;
  final double popularity;
  final double price;
  final String imgUrl;
  final int discout;
  final String description;
  Color bgColor;
  String categoryId;
  final String publishPlace;

  Books({
    required this.id,
    required this.title,
    required this.author,
    required this.ganre,
    required this.date,
    required this.language,
    required this.pageLength,
    required this.popularity,
    required this.price,
    required this.imgUrl,
    required this.discout,
    required this.description,
    required this.bgColor,
    required this.categoryId,
    required this.publishPlace,
  });
}
