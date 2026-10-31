import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/book.dart';

/// Kitob muqovasi: keshlangan rasm, yuklanayotganda kitob rangidagi
/// "muqova" va rasm topilmasa nomi yozilgan chiroyli zaxira variant.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.width,
    this.height,
    this.radius = 14,
    this.heroTag,
    this.showShadow = true,
  });

  final Book book;
  final double? width;
  final double? height;
  final double radius;
  final String? heroTag;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    Widget cover = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: book.imgUrl.isEmpty
            ? _Fallback(book: book)
            : CachedNetworkImage(
                imageUrl: book.imgUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 250),
                placeholder: (_, __) => Container(color: book.bgColor),
                errorWidget: (_, __, ___) => _Fallback(book: book),
              ),
      ),
    );

    // Kitob qirrasi effekti — chap tomonda yupqa soya chizig'i.
    cover = Stack(
      fit: StackFit.passthrough,
      children: [
        cover,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(radius)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (showShadow) {
      cover = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: book.bgColor.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: cover,
      );
    }

    if (heroTag != null) {
      cover = Hero(tag: heroTag!, child: cover);
    }
    return cover;
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final onColor =
        book.bgColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [book.bgColor, Color.lerp(book.bgColor, Colors.black, 0.35)!],
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_stories_rounded, color: onColor.withOpacity(0.7)),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: onColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: onColor.withOpacity(0.75), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
