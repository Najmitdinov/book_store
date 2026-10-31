import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../data/models/review.dart';
import '../../state/auth_provider.dart';
import '../../state/reviews_provider.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final reviewsProvider = context.watch<ReviewsProvider>();
    final uid = context.select<AuthProvider, String?>((a) => a.uid);
    final reviews = reviewsProvider.reviewsFor(book.id);
    final loading = reviewsProvider.isLoading(book.id);
    final mine = reviewsProvider.mine(book.id, uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 12, 8),
          child: Row(
            children: [
              Text(
                context.tr('reviews'),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (reviews != null && reviews.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${reviews.length}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _WriteReviewSheet(book: book, existing: mine),
                ),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: Text(context.tr(mine == null ? 'write_review' : 'edit')),
              ),
            ],
          ),
        ),
        if (loading && reviews == null)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (reviews == null || reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.tr('no_reviews'),
              style: TextStyle(
                color: context.colors.onSurface.withOpacity(0.55),
              ),
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
            ),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: review.userName,
                size: 32,
                colorIndex: review.userId.hashCode,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      Fmt.date(review.date, context.langCode),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: review.rating, size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              review.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({required this.book, this.existing});

  final Book book;
  final Review? existing;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  late double _rating = widget.existing?.rating ?? 5.0;
  late final _text = TextEditingController(text: widget.existing?.text ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await context.read<ReviewsProvider>().submit(
            widget.book.id,
            Review(
              userId: uid,
              userName: auth.displayName,
              rating: _rating,
              text: _text.text.trim(),
              date: DateTime.now(),
            ),
          );
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, context.tr('review_sent'));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(context.tr('your_rating')),
          const SizedBox(height: 6),
          Center(
            child: RatingStars(
              rating: _rating,
              size: 40,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            maxLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: context.tr('review_hint')),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(context.tr('save')),
          ),
        ],
      ),
    );
  }
}
