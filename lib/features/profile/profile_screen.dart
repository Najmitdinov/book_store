import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/env.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../state/auth_provider.dart';
import '../../state/library_provider.dart';
import '../../state/load_state.dart';
import '../../state/orders_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/wishlist_provider.dart';
import '../library/library_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orders = context.read<OrdersProvider>();
      if (orders.status == LoadStatus.idle) orders.load();
    });
  }

  Future<void> _logout() async {
    final ok = await confirmDialog(
      context,
      title: context.tr('logout_confirm'),
      confirmLabel: context.tr('logout'),
      destructive: true,
    );
    if (!ok || !mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    await context.read<AuthProvider>().logout();
  }

  Future<void> _changePassword() async {
    try {
      await context.read<AuthProvider>().sendPasswordReset();
      if (mounted) showSnack(context, context.tr('change_password_sent'));
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final ordersCount = context.select<OrdersProvider, int>((o) => o.orders.length);
    final wishCount = context.select<WishlistProvider, int>((w) => w.count);
    final finished =
        context.select<LibraryProvider, int>((l) => l.finishedTotal);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile_title'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // ---- Profil kartasi ----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    UserAvatar(
                      name: auth.displayName,
                      colorIndex: auth.profile?.avatarColor ?? 0,
                      size: 64,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  auth.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (auth.isAdmin) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    context.tr('admin_badge'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.onSurface.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: context.tr('edit_profile'),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const _EditProfileSheet(),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Stat(value: ordersCount, label: context.tr('stats_orders')),
                    _Stat(value: wishCount, label: context.tr('stats_wishlist')),
                    _Stat(value: finished, label: context.tr('stats_finished')),
                  ],
                ),
              ],
            ),
          ),

          _Group(
            children: [
              _Tile(
                icon: Icons.receipt_long_rounded,
                title: context.tr('my_orders'),
                onTap: () => Navigator.of(context).pushNamed(Routes.orders),
              ),
              _Tile(
                icon: Icons.flag_rounded,
                title: context.tr('reading_goal'),
                trailing: Text(
                  '${context.watch<LibraryProvider>().goal}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () =>
                    showGoalEditor(context, context.read<LibraryProvider>()),
              ),
            ],
          ),

          if (auth.isAdmin)
            _Group(
              title: context.tr('admin_panel'),
              children: [
                _Tile(
                  icon: Icons.library_books_rounded,
                  title: context.tr('manage_books'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(Routes.manageBooks),
                ),
                _Tile(
                  icon: Icons.local_shipping_rounded,
                  title: context.tr('all_orders'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(Routes.adminOrders),
                ),
              ],
            ),

          _Group(
            title: context.tr('settings'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    const Icon(Icons.palette_outlined),
                    const SizedBox(width: 16),
                    Text(context.tr('theme')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.accent,
                      selectedForegroundColor: Colors.white,
                    ),
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_rounded),
                        label: Text(context.tr('theme_system')),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_rounded),
                        label: Text(context.tr('theme_light')),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_rounded),
                        label: Text(context.tr('theme_dark')),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => settings.setThemeMode(s.first),
                  ),
                ),
              ),
              _Tile(
                icon: Icons.translate_rounded,
                title: context.tr('language_setting'),
                trailing: DropdownButton<String>(
                  value: settings.locale.languageCode,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(14),
                  items: const [
                    DropdownMenuItem(value: 'uz', child: Text("🇺🇿 O'zbekcha")),
                    DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Русский')),
                    DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  ],
                  onChanged: (v) {
                    if (v != null) settings.setLanguage(v);
                  },
                ),
              ),
              _Tile(
                icon: Icons.lock_reset_rounded,
                title: context.tr('change_password'),
                onTap: _changePassword,
              ),
              _Tile(
                icon: Icons.info_outline_rounded,
                title: context.tr('about'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: Env.appName,
                  applicationVersion: '2.0.0',
                  applicationIcon: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.accent,
                    size: 40,
                  ),
                  children: [Text(context.tr('about_body'))],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.error,
              side: BorderSide(color: context.colors.error.withOpacity(0.4)),
            ),
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: Text(context.tr('logout')),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${Env.appName} · ${context.tr('version')} 2.0.0',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 700),
            builder: (_, v, __) => Text(
              '$v',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurface.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 22, 6, 8),
          child: title == null
              ? const SizedBox.shrink()
              : Text(
                  title!,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.colors.onSurface.withOpacity(0.55),
                  ),
                ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ??
          (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      onTap: onTap,
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final AuthProvider _auth = context.read<AuthProvider>();
  late final _name = TextEditingController(text: _auth.profile?.name ?? '');
  late int _color = _auth.profile?.avatarColor ?? 0;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await _auth.updateProfile(name: _name.text.trim(), avatarColor: _color);
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, context.tr('profile_saved'));
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
            context.tr('edit_profile'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Center(
            child: ValueListenableBuilder(
              valueListenable: _name,
              builder: (_, value, __) => UserAvatar(
                name: value.text.isEmpty ? _auth.email : value.text,
                colorIndex: _color,
                size: 84,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < UserAvatar.palettes.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _color = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: UserAvatar.palettes[i]),
                      border: Border.all(
                        color: _color == i
                            ? context.colors.onSurface
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: context.tr('name'),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
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
