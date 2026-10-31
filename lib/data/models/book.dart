import 'package:flutter/material.dart';

import 'json_utils.dart';

/// Kitob modeli (o'zgarmas).
///
/// Firebase'dagi eski kalit nomlari (`ganre`, `discout`) saqlanib qolgan —
/// mavjud ma'lumotlar buzilmasligi uchun.
@immutable
class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final DateTime date;
  final List<String> languages;
  final int pageLength;

  /// 0–5 oralig'idagi reyting.
  final double popularity;
  final double price;
  final String imgUrl;

  /// Chegirma foizi (0–90).
  final int discount;
  final String description;
  final Color bgColor;
  final String categoryId;
  final String publishPlace;
  final String? creatorId;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.date,
    required this.languages,
    required this.pageLength,
    required this.popularity,
    required this.price,
    required this.imgUrl,
    required this.discount,
    required this.description,
    required this.bgColor,
    this.categoryId = '',
    this.publishPlace = '',
    this.creatorId,
  });

  bool get hasDiscount => discount > 0;

  /// Chegirma qo'llangan yakuniy narx.
  double get finalPrice =>
      hasDiscount ? price * (100 - discount) / 100 : price;

  /// Taxminiy o'qish vaqti (soatda): o'rtacha 40 sahifa/soat.
  int get readingHours => (pageLength / 40).ceil().clamp(1, 999);

  /// "Yangi" — oxirgi 60 kun ichida qo'shilgan/nashr etilgan.
  bool get isNew => DateTime.now().difference(date).inDays <= 60;

  factory Book.fromJson(String id, Map<String, dynamic> json) {
    return Book(
      id: id,
      title: asString(json['title'], '—'),
      author: asString(json['author'], '—'),
      genre: asString(json['ganre'] ?? json['genre']),
      date: asDate(json['date']),
      languages: asStringList(json['language']),
      pageLength: asInt(json['pageLength']),
      popularity: asDouble(json['popularity']).clamp(0, 5).toDouble(),
      price: asDouble(json['price']),
      imgUrl: asString(json['imgUrl']),
      discount: asInt(json['discout'] ?? json['discount']).clamp(0, 90),
      description: asString(json['description']),
      bgColor: Color(asInt(json['bgColor'], 0xFF3D3A35)),
      categoryId: asString(json['categoryId']),
      publishPlace: asString(json['publishPlace']),
      creatorId: json['creatorId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'author': author,
        'ganre': genre,
        'date': date.toIso8601String(),
        'language': languages,
        'pageLength': pageLength,
        'popularity': popularity,
        'price': price,
        'imgUrl': imgUrl,
        'discout': discount,
        'description': description,
        'bgColor': bgColor.value,
        'categoryId': categoryId,
        'publishPlace': publishPlace,
        if (creatorId != null) 'creatorId': creatorId,
      };

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    DateTime? date,
    List<String>? languages,
    int? pageLength,
    double? popularity,
    double? price,
    String? imgUrl,
    int? discount,
    String? description,
    Color? bgColor,
    String? categoryId,
    String? publishPlace,
    String? creatorId,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      date: date ?? this.date,
      languages: languages ?? this.languages,
      pageLength: pageLength ?? this.pageLength,
      popularity: popularity ?? this.popularity,
      price: price ?? this.price,
      imgUrl: imgUrl ?? this.imgUrl,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      bgColor: bgColor ?? this.bgColor,
      categoryId: categoryId ?? this.categoryId,
      publishPlace: publishPlace ?? this.publishPlace,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  @override
  bool operator ==(Object other) => other is Book && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
