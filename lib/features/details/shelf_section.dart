import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../data/models/shelf_entry.dart';
import '../../state/library_provider.dart';

/// Kitobni shaxsiy javonga qo'yish va o'qish jarayonini belgilash.
class ShelfSection extends StatelessWidget {
  const ShelfSection({super.key, required this.book});

  final Book book;

  static const _icons = {
    Shelf.want: Icons.bookmark_add_outlined,
    Shelf.reading: Icons.menu_book_rounded,
    Shelf.finished: Icons.verified_rounded,
  };

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final entry = library.entryFor(book.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr('add_to_shelf'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (entry != null)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () =>
                      _run(context, () => library.removeFromShelf(book.id)),
                  child: Text(context.tr('shelf_remove')),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final shelf in Shelf.values) ...[
                Expanded(
                  child: _ShelfChip(
                    icon: _icons[shelf]!,
                    label: context.tr(shelf.labelKey),
                    selected: entry?.shelf == shelf,
                    onTap: () =>
                        _run(context, () => library.setShelf(book, shelf)),
                  ),
                ),
                if (shelf != Shelf.values.last) const SizedBox(width: 8),
              ],
            ],
          ),
          if (entry?.shelf == Shelf.reading && book.pageLength > 0)
            _ProgressEditor(book: book, entry: entry!),
        ],
      ),
    );
  }
}

class _ShelfChip extends StatelessWidget {
  const _ShelfChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.sage
            : context.colors.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : null, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressEditor extends StatefulWidget {
  const _ProgressEditor({required this.book, required this.entry});

  final Book book;
  final ShelfEntry entry;

  @override
  State<_ProgressEditor> createState() => _ProgressEditorState();
}

class _ProgressEditorState extends State<_ProgressEditor> {
  late double _page = widget.entry.currentPage.toDouble();

  @override
  void didUpdateWidget(covariant _ProgressEditor old) {
    super.didUpdateWidget(old);
    if (old.entry.currentPage != widget.entry.currentPage) {
      _page = widget.entry.currentPage.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.book.pageLength.toDouble();
    final changed = _page.round() != widget.entry.currentPage;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr('progress_page', {
                  'n': '${_page.round()}',
                  'm': '${widget.book.pageLength}',
                }),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${(_page / total * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.sage,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: _page.clamp(0.0, total),
            max: total,
            activeColor: AppColors.sage,
            onChanged: (v) => setState(() => _page = v),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: changed
                ? SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sage,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: () async {
                        try {
                          await context
                              .read<LibraryProvider>()
                              .updateProgress(widget.book, _page.round());
                        } catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      },
                      child: Text(
                        context.tr('update_progress'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
