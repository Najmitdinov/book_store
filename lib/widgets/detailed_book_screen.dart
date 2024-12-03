import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../models/books.dart';

class DetailedBookScreen extends StatelessWidget {
  final Books bookData;
  const DetailedBookScreen(
    this.bookData, {
    super.key,
  });

  Widget details(
    Widget widget,
    String title,
    Widget subWidget,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          widget,
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              subWidget,
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 40.0,
            left: 10,
            right: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.network(
                        bookData.imgUrl,
                        width: 50,
                        height: 60,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edition details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Book',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 30,
              ),
              const Text(
                'Publisher descreption',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                bookData.description,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              const Divider(
                height: 40,
              ),
              details(
                  Text(
                    bookData.popularity.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  'Book Rating',
                  Row(
                    children: [
                      1,
                      2,
                      3,
                      4,
                      5,
                    ].map((star) {
                      return Icon(
                        Icons.star,
                        color: bookData.popularity.ceil() >= star
                            ? Colors.white
                            : Colors.grey,
                        size: 15,
                      );
                    }).toList(),
                  )),
              details(
                const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                ),
                'Realesed',
                Text(
                  DateFormat('d MMMM yyy').format(bookData.date),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              details(
                const Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                'Languages',
                Row(
                  children: bookData.language.map(
                    (language) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          language,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              details(
                const Icon(
                  Icons.smart_button,
                  color: Colors.white,
                ),
                'Length',
                Text(
                  '${bookData.pageLength} page',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              bookData.discout > 1
                  ? details(
                      const Icon(
                        Icons.discount,
                        color: Colors.white,
                      ),
                      'Discount',
                      Text(
                        '${bookData.discout}% disount',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
              details(
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                ),
                'Publisher',
                Text(
                  bookData.publishPlace,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
