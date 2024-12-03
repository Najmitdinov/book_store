import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../models/books.dart';

class Book with ChangeNotifier {
  List<Books> _book = [];

  double calculatedDiscount(String id) {
    double discount = 0.0;
    for (var bookData in _book) {
      if (bookData.id == id && bookData.discout > 1) {
        var discoutPecentage = bookData.price * (bookData.discout / 100);
        discount += bookData.price - discoutPecentage;
      }
    }
    return discount;
  }

  String? _authToken;
  String? _userId;

  void setParams(String? authToken, String? userId) {
    _authToken = authToken;
    _userId = userId;
  }

  Future<void> addNewBook(Books book) async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/books.json?auth=$_authToken');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'title': book.title,
            'author': book.author,
            'ganre': book.ganre,
            'date': book.date.toIso8601String(),
            'language': book.language,
            'pageLength': book.pageLength,
            'popularity': book.popularity,
            'price': book.price,
            'imgUrl': book.imgUrl,
            'discout': book.discout,
            'description': book.description,
            'bgColor': book.bgColor.value,
            'categoryId': book.categoryId,
            'publishPlace': book.publishPlace,
            'creatorId': _userId,
          },
        ),
      );
      final productId = jsonDecode(response.body)['name'];
      final _newBook = Books(
        id: productId,
        title: book.title,
        author: book.author,
        ganre: book.ganre,
        date: book.date,
        language: book.language,
        pageLength: book.pageLength,
        popularity: book.popularity,
        price: book.price,
        imgUrl: book.imgUrl,
        discout: book.discout,
        description: book.description,
        bgColor: book.bgColor,
        categoryId: book.categoryId,
        publishPlace: book.publishPlace,
      );
      _book.add(_newBook);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> upDataBook(Books updatingBook) async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/books/${updatingBook.id}.json?auth=$_authToken');
    final bookIndex = _book.indexWhere((book) => book.id == updatingBook.id);
    if (bookIndex >= 0) {
      try {
        http.patch(
          url,
          body: jsonEncode(
            {
              'title': updatingBook.title,
              'author': updatingBook.author,
              'ganre': updatingBook.ganre,
              'date': updatingBook.date.toIso8601String(),
              'language': updatingBook.language,
              'pageLength': updatingBook.pageLength,
              'popularity': updatingBook.popularity,
              'price': updatingBook.price,
              'imgUrl': updatingBook.imgUrl,
              'discout': updatingBook.discout,
              'description': updatingBook.description,
              'bgColor': updatingBook.bgColor.value,
              'categoryId': updatingBook.categoryId,
              'publishPlace': updatingBook.publishPlace,
            },
          ),
        );
        _book[bookIndex] = updatingBook;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> getBooksFromFireBase([bool filterUsers = false]) async {
    final filter = filterUsers ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/books.json?auth=$_authToken&$filter');
    try {
      final response = await http.get(url);

      final List<Books> _uploadedBook = [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      data.forEach(
        (id, book) {
          List<String> language = (book['language'] as List<dynamic>)
              .map((book) => book as String)
              .toList();
          _uploadedBook.add(
            Books(
              id: id,
              title: book['title'],
              author: book['author'],
              ganre: book['ganre'],
              date: DateTime.parse(book['date']),
              language: language,
              pageLength: book['pageLength'],
              popularity: book['popularity'],
              price: book['price'],
              imgUrl: book['imgUrl'],
              discout: book['discout'],
              description: book['description'],
              bgColor: Color(book['bgColor']),
              categoryId: book['categoryId'],
              publishPlace: book['publishPlace'],
            ),
          );
        },
      );
      _book = _uploadedBook;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteBook(String id) async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/books/$id.json?auth=$_authToken');

    try {
      final deletingBook = _book.firstWhere((book) => book.id == id);
      final bookIndex = _book.indexWhere((book) => book.id == id);
      _book.removeWhere((book) => book.id == id);
      notifyListeners();

      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        _book.insert(bookIndex, deletingBook);
        notifyListeners();
        throw Exception();
      }
    } catch (error) {
      rethrow;
    }
  }

  List<Books> get wishedList {
    return _wishedList;
  }

  Books findById(String id) {
    return _book.firstWhere((book) => book.id == id);
  }

  List<Books> _wishedList = [];

  Future<void> addToWishedList(String title, String imgUrl, String id) async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/wishList/$_userId/$id.json?auth=$_authToken');

    final bookIndex = _wishedList.indexWhere((book) => book.id == id);
    if (bookIndex < 0) {
      try {
        await http.post(
          url,
          body: jsonEncode(
            {
              'title': title,
              'imgUrl': imgUrl,
            },
          ),
        );
        _wishedList.insert(0, _book.firstWhere((prod) => prod.id == id));
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> getWishedBooksFromFireBase() async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/wishList/$_userId.json?auth=$_authToken');

    try {
      final respone = await http.get(url);
      if (jsonDecode(respone.body) == null) {
        return;
      }
      final List<Books> _uploadedWishedList = [];
      final data = jsonDecode(respone.body) as Map<String, dynamic>;
      data.forEach((key, wishedBook) {
        List<String> language = (wishedBook['language'] != null
                ? (wishedBook['language'] as List<dynamic>)
                : [])
            .map((book) => book! as String)
            .toList();
        _uploadedWishedList.add(
          Books(
            id: key,
            title: wishedBook['title'],
            author: wishedBook['author'] ?? 'Unknown Author',
            ganre: wishedBook['ganre'] ?? 'Unknown ganre',
            date: wishedBook['date'] != null
                ? DateTime.parse(wishedBook['date'])
                : DateTime.now(), // Default to current date if null
            language: language,
            pageLength: wishedBook['pageLength'] ?? 0, // Default to 0 if null
            popularity: wishedBook['popularity'] ?? 0, // Default to 0 if null
            price: wishedBook['price'] ?? 0.0, // Default to 0.0 if null
            imgUrl: wishedBook['imgUrl'],
            discout: wishedBook['discout'] ?? 0,
            description: wishedBook['description'] ?? 'No Description',
            bgColor: wishedBook['bgColor'] != null
                ? Color(wishedBook['bgColor'])
                : Colors.grey, // Default color
            categoryId: wishedBook['categoryId'] ?? 'Unknown Category',
            publishPlace: wishedBook['publishPlace'] ?? 'Unknown Place',
          ),
        );
      });
      _wishedList = _uploadedWishedList;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteFromWishedList(String id) async {
    final url = Uri.parse(
        'https://book-store-14cd2-default-rtdb.firebaseio.com/wishList/$_userId/$id.json?auth=$_authToken');

    final bookIndex = _wishedList.indexWhere((book) => book.id == id);
    if (bookIndex >= 0) {
      try {
        await http.delete(url);
        _wishedList.removeWhere((wished) => wished.id == id);
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  List<Books> get book {
    return _book;
  }
}
