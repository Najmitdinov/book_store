import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/external_book_card.dart';
import '../../data/models/book.dart';
import '../../data/models/external_book.dart';
import '../../state/auth_provider.dart';
import '../../state/catalog_provider.dart';

class ExternalBookScreen extends StatefulWidget {
  const ExternalBookScreen({super.key, required this.book});

  final ExternalBook book;

  @override
  State<ExternalBookScreen> createState() => _ExternalBookScreenState();
}

class _ExternalBookScreenState extends State<ExternalBookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CatalogProvider>().loadDescription(widget.book),
    );
  }

  /// Global kitobdan do'kon uchun qoralama — admin faqat narx yozadi.
  Book _toDraft(String? description) {
    final b = widget.book;
    return Book(
      id: '',
      title: b.title,
      author: b.author,
      genre: b.subjects.isEmpty ? '' : b.subjects.first,
      date: DateTime(b.year ?? DateTime.now().year),
      languages: b.languages.isEmpty ? const ['en'] : b.languages,
      pageLength: b.pageCount ?? 0,
      popularity: 4.5,
      price: 0,
      imgUrl: b.coverUrl ?? '',
      discount: 0,
      description: description ?? '',
      bgColor: const Color(0xFF3D5A80),
      publishPlace: b.source.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;
    final catalog = context.watch<CatalogProvider>();
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);
    final description = catalog.descriptionFor(b);
    final descLoading = !catalog.hasDescriptionLoaded(b);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Muqovaning xira foni
                  Opacity(
                    opacity: 0.35,
                    child: ExternalCover(book: b, radius: 0),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, AppColors.ink],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ExternalCover(
                            book: b,
                            width: 190,
                            height: 285,
                            radius: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(text: b.source.label, color: AppColors.accent),
                      if (b.canRead)
                        _Pill(
                          text: context.tr('free_badge'),
                          color: AppColors.sage,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    b.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.author,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colors.onSurface.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Facts(book: b),
                  const SizedBox(height: 20),
                  if (b.canRead)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sage,
                      ),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(Routes.reader, arguments: b),
                      icon: const Icon(Icons.chrome_reader_mode_rounded,
                          color: Colors.white),
                      label: Text(
                        context.tr('read_free'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.accent),
                          const SizedBox(width: 10),
                          Expanded(child: Text(context.tr('not_for_sale'))),
                        ],
                      ),
                    ),
                  if (isAdmin) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(
                        Routes.editBook,
                        arguments: _toDraft(description),
                      ),
                      icon: const Icon(Icons.add_business_rounded),
                      label: Text(context.tr('import_to_store')),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    context.tr('description'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (descLoading)
                    const Column(
                      children: [
                        Skeleton(height: 14),
                        SizedBox(height: 8),
                        Skeleton(height: 14),
                        SizedBox(height: 8),
                        Skeleton(height: 14, width: 200),
                      ],
                    )
                  else
                    Text(
                      (description == null || description.trim().isEmpty)
                          ? '—'
                          : description.trim(),
                      style: TextStyle(
                        height: 1.6,
                        color: context.colors.onSurface.withOpacity(0.8),
                      ),
                    ),
                  if (b.subjects.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      context.tr('subjects'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in b.subjects)
                          Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                  if (b.infoUrl != null) ...[
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: b.infoUrl!));
                        if (context.mounted) {
                          showSnack(context, context.tr('link_copied'));
                        }
                      },
                      icon: const Icon(Icons.link_rounded),
                      label: Text(context.tr('copy_link')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.book});
  final ExternalBook book;

  @override
  Widget build(BuildContext context) {
    final facts = <(IconData, String, String)>[
      if (book.year != null)
        (Icons.event_rounded, '${book.year}', context.tr('year_label')),
      if (book.pageCount != null && book.pageCount! > 0)
        (Icons.menu_book_rounded, '${book.pageCount}', context.tr('pages')),
      if (book.languages.isNotEmpty)
        (
          Icons.translate_rounded,
          book.languages.take(3).map((l) => l.toUpperCase()).join(', '),
          context.tr('language_label'),
        ),
      if (book.downloads != null)
        (Icons.download_rounded, '${book.downloads}', context.tr('downloads')),
    ];
    if (facts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final f in facts)
            Expanded(
              child: Column(
                children: [
                  Icon(f.$1, color: AppColors.accent, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    f.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    f.$3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
