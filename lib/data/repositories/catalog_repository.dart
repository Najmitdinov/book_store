import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/env.dart';
import '../../core/network/app_exception.dart';
import '../models/external_book.dart';
import '../models/json_utils.dart';

/// Bir sahifa natija + keyingi sahifa bormi.
class CatalogPage {
  const CatalogPage(this.books, {required this.hasMore, this.total});
  final List<ExternalBook> books;
  final bool hasMore;
  final int? total;
}

enum CatalogSort { relevance, newest, oldest, popular }

/// Ochiq kitob kataloglari: Open Library, Project Gutenberg (Gutendex),
/// Google Books. Hech biri Firebase'ga yozilmaydi — jonli qidiruv.
class CatalogRepository {
  CatalogRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const pageSize = 20;

  Future<CatalogPage> search({
    required CatalogSource source,
    String query = '',
    CatalogSort sort = CatalogSort.relevance,
    String? language,
    int page = 1,
  }) {
    switch (source) {
      case CatalogSource.openLibrary:
        return _openLibrary(query, sort, language, page);
      case CatalogSource.gutenberg:
        return _gutenberg(query, sort, language, page);
      case CatalogSource.google:
        return _google(query, sort, language, page);
    }
  }

  /// Open Library'dan to'liq tavsifni olish (qidiruv natijasida bo'lmaydi).
  Future<String?> fetchDescription(ExternalBook book) async {
    if (book.description != null && book.description!.isNotEmpty) {
      return book.description;
    }
    if (book.source != CatalogSource.openLibrary) return null;
    try {
      final data = asMap(await _getJson(
        Uri.parse('https://openlibrary.org/works/${book.id}.json'),
      ));
      final d = data['description'];
      if (d is String) return d;
      if (d is Map) return asString(d['value']);
    } catch (_) {}
    return null;
  }

  /// Gutenberg kitobining to'liq matni (litsenziya sarlavhalarisiz).
  Future<String> fetchText(ExternalBook book) async {
    final url = book.textUrl;
    if (url == null) throw const AppException('err_unknown');
    final http.Response res;
    try {
      res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 40));
    } on SocketException {
      throw const AppException('err_network');
    } on TimeoutException {
      throw const AppException('err_timeout');
    } on http.ClientException {
      throw const AppException('err_network');
    }
    if (res.statusCode >= 400) {
      throw AppException('err_server', '${res.statusCode}');
    }
    final text = utf8.decode(res.bodyBytes, allowMalformed: true);
    return _stripGutenberg(text);
  }

  // ---------------- Open Library ----------------

  Future<CatalogPage> _openLibrary(
    String query,
    CatalogSort sort,
    String? language,
    int page,
  ) async {
    final year = DateTime.now().year;
    final q = query.trim().isNotEmpty
        ? query.trim()
        : switch (sort) {
            // Bo'sh qidiruvda ma'noli kolleksiya ko'rsatamiz.
            CatalogSort.oldest => 'first_publish_year:[1 TO 1900]',
            _ => 'first_publish_year:[${year - 2} TO $year]',
          };
    final params = <String, String>{
      'q': q,
      'fields':
          'key,title,author_name,first_publish_year,cover_i,language,subject,number_of_pages_median,ia',
      'limit': '$pageSize',
      'page': '$page',
      if (language != null) 'language': _toOlLang(language),
      if (sort == CatalogSort.newest) 'sort': 'new',
      if (sort == CatalogSort.oldest) 'sort': 'old',
    };
    final data = asMap(await _getJson(
      Uri.https('openlibrary.org', '/search.json', params),
    ));
    final docs = (data['docs'] as List?) ?? const [];
    final total = asInt(data['numFound'] ?? data['num_found']);
    final books = docs.whereType<Map>().map((raw) {
      final d = asMap(raw);
      final key = asString(d['key']).replaceAll('/works/', '');
      final coverId = d['cover_i'];
      return ExternalBook(
        id: key,
        source: CatalogSource.openLibrary,
        title: asString(d['title'], '—'),
        authors: asStringList(d['author_name']),
        year: d['first_publish_year'] == null
            ? null
            : asInt(d['first_publish_year']),
        coverUrl: coverId == null
            ? null
            : 'https://covers.openlibrary.org/b/id/$coverId-L.jpg',
        subjects: asStringList(d['subject']).take(8).toList(),
        languages: asStringList(d['language']).take(6).toList(),
        pageCount: d['number_of_pages_median'] == null
            ? null
            : asInt(d['number_of_pages_median']),
        infoUrl: 'https://openlibrary.org/works/$key',
      );
    }).toList();
    return CatalogPage(books, hasMore: page * pageSize < total, total: total);
  }

  static String _toOlLang(String code) => switch (code) {
        'uz' => 'uzb',
        'ru' => 'rus',
        'en' => 'eng',
        'de' => 'ger',
        'fr' => 'fre',
        'tr' => 'tur',
        _ => code,
      };

  // ---------------- Project Gutenberg (Gutendex) ----------------

  Future<CatalogPage> _gutenberg(
    String query,
    CatalogSort sort,
    String? language,
    int page,
  ) async {
    final params = <String, String>{
      if (query.trim().isNotEmpty) 'search': query.trim(),
      if (language != null) 'languages': language,
      'page': '$page',
      // Gutendex: popular (standart), ascending/descending — ID bo'yicha.
      'sort': switch (sort) {
        CatalogSort.newest => 'descending',
        CatalogSort.oldest => 'ascending',
        _ => 'popular',
      },
      if (sort == CatalogSort.oldest) 'author_year_end': '1800',
    };
    final data = asMap(await _getJson(
      Uri.https('gutendex.com', '/books', params),
    ));
    final results = (data['results'] as List?) ?? const [];
    final books = results.whereType<Map>().map((raw) {
      final b = asMap(raw);
      final formats = asMap(b['formats']);
      String? text;
      for (final entry in formats.entries) {
        final mime = entry.key.toLowerCase();
        final url = asString(entry.value);
        if (mime.startsWith('text/plain') && !url.endsWith('.zip')) {
          text = url;
          if (mime.contains('utf-8')) break;
        }
      }
      final authors = (b['authors'] as List? ?? const [])
          .whereType<Map>()
          .map((a) => _flipName(asString(a['name'])))
          .where((n) => n.isNotEmpty)
          .toList();
      final firstAuthor = (b['authors'] as List? ?? const [])
          .whereType<Map>()
          .firstOrNull;
      final summaries = asStringList(b['summaries']);
      final id = asString(b['id']);
      return ExternalBook(
        id: id,
        source: CatalogSource.gutenberg,
        title: asString(b['title'], '—'),
        authors: authors,
        // Nashr yili yo'q — muallif yashagan davrni ko'rsatamiz.
        year: firstAuthor == null || firstAuthor['death_year'] == null
            ? null
            : asInt(firstAuthor['death_year']),
        coverUrl: formats['image/jpeg']?.toString(),
        description: summaries.isEmpty ? null : summaries.first,
        subjects: [
          ...asStringList(b['bookshelves'])
              .map((s) => s.replaceFirst('Category: ', '')),
          ...asStringList(b['subjects']),
        ].take(8).toList(),
        languages: asStringList(b['languages']),
        textUrl: text,
        infoUrl: 'https://www.gutenberg.org/ebooks/$id',
        downloads: b['download_count'] == null
            ? null
            : asInt(b['download_count']),
      );
    }).toList();
    return CatalogPage(
      books,
      hasMore: data['next'] != null,
      total: asInt(data['count']),
    );
  }

  /// "Tolstoy, Leo" → "Leo Tolstoy".
  static String _flipName(String name) {
    final parts = name.split(', ');
    if (parts.length == 2) return '${parts[1]} ${parts[0]}';
    return name;
  }

  // ---------------- Google Books ----------------

  Future<CatalogPage> _google(
    String query,
    CatalogSort sort,
    String? language,
    int page,
  ) async {
    final q = query.trim().isEmpty ? 'subject:fiction' : query.trim();
    final params = <String, String>{
      'q': q,
      'maxResults': '$pageSize',
      'startIndex': '${(page - 1) * pageSize}',
      'printType': 'books',
      if (sort == CatalogSort.newest) 'orderBy': 'newest',
      if (language != null) 'langRestrict': language,
      if (Env.googleBooksApiKey.isNotEmpty) 'key': Env.googleBooksApiKey,
    };
    final data = asMap(await _getJson(
      Uri.https('www.googleapis.com', '/books/v1/volumes', params),
    ));
    final items = (data['items'] as List?) ?? const [];
    final total = asInt(data['totalItems']);
    final books = items.whereType<Map>().map((raw) {
      final item = asMap(raw);
      final info = asMap(item['volumeInfo']);
      final images = asMap(info['imageLinks']);
      final cover = asString(images['thumbnail'] ?? images['smallThumbnail']);
      final published = asString(info['publishedDate']);
      return ExternalBook(
        id: asString(item['id']),
        source: CatalogSource.google,
        title: asString(info['title'], '—'),
        authors: asStringList(info['authors']),
        year: published.length >= 4 ? int.tryParse(published.substring(0, 4)) : null,
        coverUrl: cover.isEmpty
            ? null
            : cover.replaceFirst('http://', 'https://').replaceAll('&edge=curl', ''),
        description: info['description']?.toString(),
        subjects: asStringList(info['categories']),
        languages: info['language'] == null ? const [] : [asString(info['language'])],
        pageCount: info['pageCount'] == null ? null : asInt(info['pageCount']),
        infoUrl: info['infoLink']?.toString(),
      );
    }).toList();
    return CatalogPage(
      books,
      hasMore: books.length == pageSize && page * pageSize < total,
      total: total,
    );
  }

  // ---------------- Yordamchi ----------------

  Future<dynamic> _getJson(Uri uri) async {
    final http.Response res;
    try {
      res = await _client.get(uri).timeout(const Duration(seconds: 25));
    } on SocketException {
      throw const AppException('err_network');
    } on TimeoutException {
      throw const AppException('err_timeout');
    } on http.ClientException {
      throw const AppException('err_network');
    }
    if (res.statusCode == 429 || res.statusCode == 403) {
      throw const AppException('err_too_many');
    }
    if (res.statusCode >= 400) {
      throw AppException('err_server', '${res.statusCode}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static String _stripGutenberg(String text) {
    var body = text;
    final start = RegExp(r'\*\*\*\s*START OF (THE|THIS) PROJECT GUTENBERG[^\n]*\n',
            caseSensitive: false)
        .firstMatch(body);
    if (start != null) body = body.substring(start.end);
    final end = RegExp(r'\*\*\*\s*END OF (THE|THIS) PROJECT GUTENBERG',
            caseSensitive: false)
        .firstMatch(body);
    if (end != null) body = body.substring(0, end.start);
    return body.trim();
  }
}
