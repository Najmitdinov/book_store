import 'package:book_store/data/models/book.dart';
import 'package:book_store/data/models/cart_item.dart';
import 'package:book_store/data/models/order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book.fromJson', () {
    test('eski Firebase formatini (ganre, discout, int narx) o\'qiydi', () {
      final book = Book.fromJson('b1', {
        'title': 'O\'tkan kunlar',
        'author': 'Abdulla Qodiriy',
        'ganre': 'Roman',
        'date': '2024-01-10T00:00:00.000',
        'language': ['uz', 'ru'],
        'pageLength': 400,
        'popularity': 5,
        'price': 20, // int — eski versiyada qulashga sabab bo'lgan
        'imgUrl': 'https://example.com/a.jpg',
        'discout': 25,
        'description': '...',
        'bgColor': 0xFF123456,
        'categoryId': 'c1',
        'publishPlace': 'Toshkent',
      });

      expect(book.genre, 'Roman');
      expect(book.price, 20.0);
      expect(book.discount, 25);
      expect(book.finalPrice, 15.0);
      expect(book.languages, ['uz', 'ru']);
      expect(book.readingHours, 10);
    });

    test('bo\'sh/yetishmayotgan maydonlarda qulamaydi', () {
      final book = Book.fromJson('b2', {});
      expect(book.title, '—');
      expect(book.price, 0);
      expect(book.languages, isEmpty);
      expect(book.hasDiscount, isFalse);
    });

    test('toJson eski kalit nomlarini saqlaydi', () {
      final json = Book.fromJson('b3', {'ganre': 'X', 'discout': 10}).toJson();
      expect(json.containsKey('ganre'), isTrue);
      expect(json.containsKey('discout'), isTrue);
    });
  });

  group('CartItem', () {
    test('chegirmali narx va jami summa', () {
      final book = Book.fromJson('b1', {'price': 40, 'discout': 50});
      final item = CartItem.fromBook(book, quantity: 3);
      expect(item.price, 20);
      expect(item.total, 60);
      expect(item.originalTotal, 120);
    });
  });

  group('Order', () {
    test('noma\'lum status "yangi" deb olinadi va mahsulotlar Map bo\'lsa ham o\'qiladi', () {
      final order = Order.fromJson('-Nabc123xyz', 'u1', {
        'date': '2024-05-01T10:00:00.000',
        'totalPrice': 12,
        'status': '???',
        'products': {
          '0': {'id': 'b1', 'title': 'A', 'price': 6, 'quantity': 2},
        },
      });
      expect(order.status, OrderStatus.newOrder);
      expect(order.itemsCount, 2);
      expect(order.shortId, '123XYZ');
    });
  });
}
