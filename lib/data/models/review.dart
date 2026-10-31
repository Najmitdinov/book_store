import 'package:flutter/foundation.dart';

import 'json_utils.dart';

@immutable
class Review {
  final String userId;
  final String userName;
  final double rating;
  final String text;
  final DateTime date;

  const Review({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
    required this.date,
  });

  factory Review.fromJson(String userId, Map<String, dynamic> json) => Review(
        userId: userId,
        userName: asString(json['userName'], 'Kitobxon'),
        rating: asDouble(json['rating']).clamp(1, 5).toDouble(),
        text: asString(json['text']),
        date: asDate(json['date']),
      );

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'rating': rating,
        'text': text,
        'date': date.toIso8601String(),
      };
}
