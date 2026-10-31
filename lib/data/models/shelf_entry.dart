import 'package:flutter/foundation.dart';

import 'json_utils.dart';

enum Shelf {
  want('want', 'shelf_want'),
  reading('reading', 'shelf_reading'),
  finished('finished', 'shelf_finished');

  const Shelf(this.value, this.labelKey);
  final String value;
  final String labelKey;

  static Shelf parse(dynamic v) =>
      Shelf.values.firstWhere((s) => s.value == v, orElse: () => Shelf.want);
}

/// Shaxsiy javondagi kitob: qaysi javonda, nechanchi sahifada.
@immutable
class ShelfEntry {
  final String bookId;
  final Shelf shelf;
  final int currentPage;
  final DateTime updatedAt;
  final DateTime? finishedAt;

  const ShelfEntry({
    required this.bookId,
    required this.shelf,
    this.currentPage = 0,
    required this.updatedAt,
    this.finishedAt,
  });

  factory ShelfEntry.fromJson(String bookId, Map<String, dynamic> json) =>
      ShelfEntry(
        bookId: bookId,
        shelf: Shelf.parse(json['shelf']),
        currentPage: asInt(json['currentPage']),
        updatedAt: asDate(json['updatedAt']),
        finishedAt:
            json['finishedAt'] == null ? null : asDate(json['finishedAt']),
      );

  Map<String, dynamic> toJson() => {
        'shelf': shelf.value,
        'currentPage': currentPage,
        'updatedAt': updatedAt.toIso8601String(),
        if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
      };

  ShelfEntry copyWith({
    Shelf? shelf,
    int? currentPage,
    DateTime? updatedAt,
    DateTime? finishedAt,
    bool clearFinished = false,
  }) =>
      ShelfEntry(
        bookId: bookId,
        shelf: shelf ?? this.shelf,
        currentPage: currentPage ?? this.currentPage,
        updatedAt: updatedAt ?? this.updatedAt,
        finishedAt: clearFinished ? null : (finishedAt ?? this.finishedAt),
      );
}
