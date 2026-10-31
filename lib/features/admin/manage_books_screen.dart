import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/common.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/book.dart';
import '../../state/auth_provider.dart';
import '../../state/books_provider.dart';

/// Faqat adminlar uchun: kitoblar katalogini boshqarish.
class AdminGuard extends StatelessWidget {
  const AdminGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);
    if (isAdmin) return child;
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(emoji: '🔒', title: context.tr('admin_only')),
    );
  }
}

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  String _query = '';

  Future<void> _delete(Book book) async {
    final ok = await confirmDialog(
      context,
      title: context.tr('delete_book_confirm', {'title': book.title}),
      confirmLabel: context.tr('delete'),
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await context.read<BooksProvider>().delete(book.id);
      if (mounted) showSnack(context, context.tr('book_deleted'));
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();
    final q = _query.toLowerCase();
    final books = booksProvider.books
        .where((b) =>
            q.isEmpty ||
            b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('manage_books')),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: context.tr('search'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixText: context.tr(
                    'admin_books_count',
                    {'n': '${booksProvider.books.length}'},
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          onPressed: () => Navigator.of(context).pushNamed(Routes.editBook),
          icon: const Icon(Icons.add_rounded),
          label: Text(context.tr('add_book')),
        ),
        body: RefreshIndicator(
          onRefresh: () => booksProvider.load(force: true),
          child: books.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 80),
                    EmptyState(emoji: '📚', title: context.tr('no_books')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final book = books[i];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          BookCover(
                            book: book,
                            width: 48,
                            height: 72,
                            radius: 8,
                            showShadow: false,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  book.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.onSurface
                                        .withOpacity(0.55),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${Fmt.money(book.finalPrice)}'
                                  '${book.hasDiscount ? '  (-${book.discount}%)' : ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: context.tr('edit'),
                            onPressed: () => Navigator.of(context)
                                .pushNamed(Routes.editBook, arguments: book),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: context.tr('delete'),
                            onPressed: () => _delete(book),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: context.colors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
