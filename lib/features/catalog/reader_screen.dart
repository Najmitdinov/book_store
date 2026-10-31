import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/external_book.dart';
import '../../state/catalog_provider.dart';
import '../../state/load_state.dart';

enum _ReaderTheme {
  paper(Color(0xFFFAF6EF), Color(0xFF2B2620)),
  sepia(Color(0xFFF1E3C6), Color(0xFF4A3B28)),
  night(Color(0xFF14161C), Color(0xFFCFC8BC));

  const _ReaderTheme(this.bg, this.fg);
  final Color bg;
  final Color fg;
}

/// Bepul kitoblarni ilova ichida o'qish: shrift o'lchami, fon rangi va
/// o'qish jarayoni chizig'i bilan.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.book});

  final ExternalBook book;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Future<List<String>> _future = _load();
  final _scroll = ScrollController();
  double _fontSize = 18;
  _ReaderTheme _theme = _ReaderTheme.paper;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) return;
      final p = (_scroll.offset / max).clamp(0.0, 1.0);
      if ((p - _progress).abs() > 0.002) setState(() => _progress = p);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<List<String>> _load() async {
    final text = await context.read<CatalogProvider>().fetchText(widget.book);
    // Gutenberg matni qatorlarga bo'lingan — xatboshilarni tiklaymiz.
    return text
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  void _settings() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.tr('reader_theme'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  for (final t in _ReaderTheme.values)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _theme = t);
                          setSheet(() {});
                        },
                        child: Container(
                          height: 64,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: t.bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _theme == t
                                  ? AppColors.accent
                                  : Colors.black12,
                              width: _theme == t ? 2.5 : 1,
                            ),
                          ),
                          child: Text(
                            'Aa',
                            style: TextStyle(
                              color: t.fg,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.text_decrease_rounded),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 14,
                      max: 28,
                      divisions: 14,
                      activeColor: AppColors.accent,
                      onChanged: (v) {
                        setState(() => _fontSize = v);
                        setSheet(() {});
                      },
                    ),
                  ),
                  const Icon(Icons.text_increase_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _theme.bg,
      appBar: AppBar(
        backgroundColor: _theme.bg,
        foregroundColor: _theme.fg,
        title: Text(
          widget.book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: _theme.fg, fontSize: 17),
        ),
        actions: [
          IconButton(
            onPressed: _settings,
            icon: const Icon(Icons.text_fields_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 3,
            color: AppColors.accent,
            backgroundColor: _theme.fg.withOpacity(0.08),
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('reader_loading'),
                    style: TextStyle(color: _theme.fg),
                  ),
                ],
              ),
            );
          }
          if (snap.hasError || snap.data == null) {
            final err = snap.error;
            return ErrorView(
              code: err == null ? null : LoadStateMixin.codeOf(err),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final paragraphs = snap.data!;
          return Scrollbar(
            controller: _scroll,
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 60),
              itemCount: paragraphs.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  paragraphs[i],
                  style: TextStyle(
                    color: _theme.fg,
                    fontSize: _fontSize,
                    height: 1.65,
                    fontFamily: 'serif',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
