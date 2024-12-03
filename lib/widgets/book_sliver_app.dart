// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/books.dart';

import '../providers/book.dart';

import '../widgets/detailed_book_screen.dart';

class BookSliverApp extends StatefulWidget {
  final Books bookData;
  const BookSliverApp(
    this.bookData, {
    super.key,
  });

  @override
  State<BookSliverApp> createState() => _BookSliverAppState();
}

class _BookSliverAppState extends State<BookSliverApp> {
  void openDetailsScreen(BuildContext context, Books bookData) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      builder: (ctx) {
        return DetailedBookScreen(bookData);
      },
    );
  }

  bool isLoading = false;

  TextStyle textStyle(Color color, double size, FontWeight fontWeight) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _book = Provider.of<Book>(context);
    final index =
        _book.wishedList.indexWhere((book) => book.id == widget.bookData.id);

    return SliverAppBar(
      snap: true,
      pinned: true,
      floating: true,
      stretch: true,
      expandedHeight: 500,
      backgroundColor: widget.bookData.bgColor.withOpacity(0.95),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      actions: [
        isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeAlign: -3,
                ),
              )
            : IconButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (index < 0) {
                    try {
                      await _book.addToWishedList(
                        widget.bookData.title,
                        widget.bookData.imgUrl,
                        widget.bookData.id,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          content:
                              Text('Kitob istaklar sahifasiga qo\'shildi!'),
                        ),
                      );
                    } catch (e) {
                      return;
                    }
                  } else {
                    try {
                      await _book.deleteFromWishedList(widget.bookData.id);
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          content:
                              Text('Kitob istaklar sahifasidan o\'chirildi!'),
                        ),
                      );
                    } catch (e) {
                      return;
                    }
                  }
                },
                icon: Icon(
                  index < 0 ? Icons.add : Icons.check,
                ),
              ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_horiz,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(7),
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.bookData.bgColor,
                      widget.bookData.bgColor,
                      widget.bookData.bgColor,
                      Colors.black87,
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Image.network(
                    widget.bookData.imgUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Text(
              widget.bookData.title,
              style: textStyle(
                Colors.white,
                18,
                FontWeight.bold,
              ),
            ),
            Text(
              widget.bookData.author,
              style: textStyle(
                Colors.white,
                14,
                FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  size: 18,
                  color: Colors.white,
                ),
                Text(
                  '${widget.bookData.popularity.toStringAsFixed(1)} - ',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.bookData.ganre,
                  style: textStyle(
                    Colors.white,
                    14,
                    FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black87,
                    Colors.black54,
                    Colors.black45,
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Book',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.info_outline,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Text(
                      '${widget.bookData.pageLength} pages',
                      style: const TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            shadowColor: Colors.white,
                            backgroundColor: Colors.black,
                            minimumSize: const Size(150, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          label: const Text(
                            'Sample',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          icon: const Icon(
                            Icons.library_books,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            openDetailsScreen(context, widget.bookData);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(150, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          icon: const Icon(
                            Icons.info,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'Info',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
    );
  }
}
