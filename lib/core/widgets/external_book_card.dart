import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/external_book.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import '../theme/app_theme.dart';

void openExternalBook(BuildContext context, ExternalBook book) =>
    Navigator.of(context).pushNamed(Routes.externalBook, arguments: book);

/// Global katalog kitobining muqovasi (rasm bo'lmasa — chiroyli zaxira).
class ExternalCover extends StatelessWidget {
  const ExternalCover({
    super.key,
    required this.book,
    this.width,
    this.height,
    this.radius = 14,
  });

  final ExternalBook book;
  final double? width;
  final double? height;
  final double radius;

  static const _palette = [
    Color(0xFF3D5A80),
    Color(0xFF5E8C6A),
    Color(0xFFD9653B),
    Color(0xFF7B4B94),
    Color(0xFFB23A48),
    Color(0xFF264653),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[book.uniqueKey.hashCode.abs() % _palette.length];
    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.4)!],
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_stories_rounded, color: Colors.white70),
          const SizedBox(height: 6),
          Text(
            book.title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: book.coverUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: book.coverUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: color.withOpacity(0.3)),
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class ExternalBookCard extends StatelessWidget {
  const ExternalBookCard({super.key, required this.book, this.width = 140});

  final ExternalBook book;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openExternalBook(context, book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExternalCover(book: book),
                  if (book.canRead)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sage,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.tr('free_badge'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (book.year != null)
                  Text(
                    '${book.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                const Spacer(),
                Flexible(
                  child: Text(
                    book.source.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
