import 'package:flutter/foundation.dart';

/// Tashqi kataloglar.
enum CatalogSource {
  openLibrary('Open Library'),
  gutenberg('Project Gutenberg'),
  google('Google Books');

  const CatalogSource(this.label);
  final String label;
}

/// Global katalogdagi kitob (do'konga qo'shilmagan, faqat ko'rish/o'qish uchun).
@immutable
class ExternalBook {
  final String id;
  final CatalogSource source;
  final String title;
  final List<String> authors;
  final int? year;
  final String? coverUrl;
  final String? description;
  final List<String> subjects;
  final List<String> languages;
  final int? pageCount;

  /// Bepul to'liq matn (faqat Gutenberg uchun).
  final String? textUrl;

  /// Manbadagi sahifa.
  final String? infoUrl;
  final int? downloads;

  const ExternalBook({
    required this.id,
    required this.source,
    required this.title,
    this.authors = const [],
    this.year,
    this.coverUrl,
    this.description,
    this.subjects = const [],
    this.languages = const [],
    this.pageCount,
    this.textUrl,
    this.infoUrl,
    this.downloads,
  });

  String get author => authors.isEmpty ? '—' : authors.take(2).join(', ');
  bool get canRead => textUrl != null && textUrl!.isNotEmpty;

  /// Bir xil kitob turli manbalarda takrorlanmasligi uchun kalit.
  String get uniqueKey => '${source.name}:$id';

  ExternalBook copyWith({String? description}) => ExternalBook(
        id: id,
        source: source,
        title: title,
        authors: authors,
        year: year,
        coverUrl: coverUrl,
        description: description ?? this.description,
        subjects: subjects,
        languages: languages,
        pageCount: pageCount,
        textUrl: textUrl,
        infoUrl: infoUrl,
        downloads: downloads,
      );

  @override
  bool operator ==(Object other) =>
      other is ExternalBook && other.uniqueKey == uniqueKey;

  @override
  int get hashCode => uniqueKey.hashCode;
}
