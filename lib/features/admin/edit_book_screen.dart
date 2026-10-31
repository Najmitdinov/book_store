import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/common.dart';
import '../../data/models/book.dart';
import '../../state/auth_provider.dart';
import '../../state/books_provider.dart';
import 'manage_books_screen.dart';

/// Kitob qo'shish / tahrirlash. Yuqorida muqova jonli ko'rinishi —
/// admin yozayotgan narsasini darhol ko'radi.
class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key, this.book});

  final Book? book;

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _title = TextEditingController(text: widget.book?.title);
  late final _author = TextEditingController(text: widget.book?.author);
  late final _genre = TextEditingController(text: widget.book?.genre);
  late final _price = TextEditingController(
    text: widget.book == null ? '' : _num(widget.book!.price),
  );
  late final _discount = TextEditingController(
    text: widget.book == null ? '0' : '${widget.book!.discount}',
  );
  late final _pages = TextEditingController(
    text: widget.book == null ? '' : '${widget.book!.pageLength}',
  );
  late final _rating = TextEditingController(
    text: widget.book == null ? '4.5' : _num(widget.book!.popularity),
  );
  late final _imgUrl = TextEditingController(text: widget.book?.imgUrl);
  late final _description =
      TextEditingController(text: widget.book?.description);
  late final _languages = TextEditingController(
    text: widget.book?.languages.join(', ') ?? 'uz',
  );
  late final _publisher =
      TextEditingController(text: widget.book?.publishPlace);

  late DateTime _date = widget.book?.date ?? DateTime.now();
  late Color _color = widget.book?.bgColor ?? const Color(0xFF3D5A80);
  bool _saving = false;

  bool get _isEdit => widget.book != null;

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  List<TextEditingController> get _all => [
        _title,
        _author,
        _genre,
        _price,
        _discount,
        _pages,
        _rating,
        _imgUrl,
        _description,
        _languages,
        _publisher,
      ];

  @override
  void initState() {
    super.initState();
    // Jonli ko'rinish uchun.
    for (final c in [_title, _author, _imgUrl, _price, _discount]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  double _parse(String v) => double.tryParse(v.replaceAll(',', '.').trim()) ?? 0;

  Book _draft() {
    final auth = context.read<AuthProvider>();
    return Book(
      id: widget.book?.id ?? '',
      title: _title.text.trim(),
      author: _author.text.trim(),
      genre: _genre.text.trim(),
      date: _date,
      languages: _languages.text
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList(),
      pageLength: int.tryParse(_pages.text.trim()) ?? 0,
      popularity: _parse(_rating.text).clamp(0, 5).toDouble(),
      price: _parse(_price.text),
      imgUrl: _imgUrl.text.trim(),
      discount: (int.tryParse(_discount.text.trim()) ?? 0).clamp(0, 90),
      description: _description.text.trim(),
      bgColor: _color,
      categoryId: widget.book?.categoryId ?? '',
      publishPlace: _publisher.text.trim(),
      creatorId: widget.book?.creatorId ?? auth.uid,
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final books = context.read<BooksProvider>();
    try {
      final draft = _draft();
      if (_isEdit) {
        await books.update(draft);
      } else {
        await books.create(draft);
      }
      if (!mounted) return;
      showSnack(context, context.tr('book_saved'));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final first = DateTime(1800);
    final last = DateTime.now().add(const Duration(days: 365));
    final initial =
        _date.isBefore(first) ? first : (_date.isAfter(last) ? last : _date);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickColor() async {
    var temp = _color;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('pick_color')),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _color,
            availableColors: const [
              Color(0xFF1F1B16),
              Color(0xFF3D5A80),
              Color(0xFF5E8C6A),
              Color(0xFFD9653B),
              Color(0xFFE2A93B),
              Color(0xFFB23A48),
              Color(0xFF7B4B94),
              Color(0xFF2A9D8F),
              Color(0xFF264653),
              Color(0xFFE76F51),
              Color(0xFF6D597A),
              Color(0xFF355070),
              Color(0xFFB56576),
              Color(0xFF8D99AE),
              Color(0xFF606C38),
              Color(0xFFBC6C25),
            ],
            onColorChanged: (c) => temp = c,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.tr('ok')),
          ),
        ],
      ),
    );
    if (ok == true) setState(() => _color = temp);
  }

  @override
  Widget build(BuildContext context) {
    final v = Validators(context);
    final genres = context.read<BooksProvider>().genres;
    final preview = _draft();

    InputDecoration deco(String key, IconData icon) => InputDecoration(
          labelText: context.tr(key),
          prefixIcon: Icon(icon),
        );

    const gap = SizedBox(height: 14);

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr(_isEdit ? 'edit_book' : 'add_book')),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              // ---- Jonli ko'rinish ----
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [_color, Color.lerp(_color, Colors.black, 0.4)!],
                  ),
                ),
                child: Row(
                  children: [
                    BookCover(
                      key: ValueKey(preview.imgUrl),
                      book: preview,
                      width: 90,
                      height: 135,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('cover_preview'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preview.title.isEmpty ? '—' : preview.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            preview.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Fmt.money(preview.finalPrice),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: deco('title', Icons.title_rounded),
                validator: v.required,
              ),
              gap,
              TextFormField(
                controller: _author,
                textCapitalization: TextCapitalization.words,
                decoration: deco('author', Icons.person_outline_rounded),
                validator: v.required,
              ),
              gap,
              TextFormField(
                controller: _genre,
                textCapitalization: TextCapitalization.sentences,
                decoration: deco('genre_label', Icons.category_outlined),
                validator: v.required,
              ),
              if (genres.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final g in genres.take(10))
                      ActionChip(
                        label: Text(g, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _genre.text = g),
                      ),
                  ],
                ),
              ],
              gap,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: deco('price', Icons.attach_money_rounded),
                      validator: v.positiveNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _discount,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration:
                          deco('discount_percent', Icons.percent_rounded),
                      validator: v.discount,
                    ),
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pages,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: deco('page_count', Icons.menu_book_rounded),
                      validator: v.positiveNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rating,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          deco('popularity_label', Icons.star_outline_rounded),
                      validator: v.rating,
                    ),
                  ),
                ],
              ),
              gap,
              TextFormField(
                controller: _imgUrl,
                keyboardType: TextInputType.url,
                decoration: deco('image_url', Icons.image_outlined),
                validator: v.imageUrl,
              ),
              gap,
              TextFormField(
                controller: _languages,
                decoration: deco('languages_hint', Icons.translate_rounded),
                validator: v.required,
              ),
              gap,
              TextFormField(
                controller: _publisher,
                textCapitalization: TextCapitalization.words,
                decoration: deco('publisher_place', Icons.apartment_rounded),
              ),
              gap,
              TextFormField(
                controller: _description,
                minLines: 4,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: deco('description_label', Icons.notes_rounded)
                    .copyWith(alignLabelWithHint: true),
                validator: v.required,
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    child: _PickerTile(
                      icon: Icons.event_rounded,
                      label: context.tr('publish_date'),
                      value: Fmt.date(_date, context.langCode),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerTile(
                      icon: Icons.palette_outlined,
                      label: context.tr('cover_color'),
                      valueWidget: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      onTap: _pickColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, color: Colors.white),
              label: Text(
                context.tr('save'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.onSurface.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    valueWidget ??
                        Text(
                          value ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
