import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/common.dart';
import '../../state/auth_provider.dart';
import '../../state/settings_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    try {
      if (_isLogin) {
        await auth.signIn(_email.text, _password.text);
      } else {
        await auth.signUp(_name.text, _email.text, _password.text);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _forgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ResetPasswordSheet(initialEmail: _email.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = Validators(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: _LanguageSwitcher(),
                    ),
                    const SizedBox(height: 12),
                    const _AuthHeader(),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(_isLogin),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(_isLogin ? 'auth_welcome' : 'signup'),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr(_isLogin
                                ? 'auth_subtitle_login'
                                : 'auth_subtitle_signup'),
                            style: TextStyle(
                              color:
                                  context.colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _isLogin
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: context.tr('full_name'),
                                  prefixIcon:
                                      const Icon(Icons.person_outline_rounded),
                                ),
                                validator: v.required,
                              ),
                            ),
                    ),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        hintText: context.tr('email'),
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                      ),
                      validator: v.email,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction:
                          _isLogin ? TextInputAction.done : TextInputAction.next,
                      onFieldSubmitted: (_) => _isLogin ? _submit() : null,
                      decoration: InputDecoration(
                        hintText: context.tr('password'),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: v.password,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _isLogin
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: Text(context.tr('forgot_password')),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: TextFormField(
                                controller: _confirm,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: context.tr('confirm_password'),
                                  prefixIcon:
                                      const Icon(Icons.lock_reset_rounded),
                                ),
                                validator: (value) => value != _password.text
                                    ? context.tr('v_password_match')
                                    : null,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: context.colors.onPrimary,
                              ),
                            )
                          : Text(context.tr(_isLogin ? 'login' : 'signup')),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr(
                              _isLogin ? 'no_account' : 'have_account'),
                        ),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => setState(() => _isLogin = !_isLogin),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                          ),
                          child: Text(
                            context.tr(_isLogin ? 'signup' : 'login'),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    // Javondagi kitob "umurtqalari" — dekorativ illyustratsiya.
    const spines = [
      (h: 92.0, c: AppColors.accent),
      (h: 120.0, c: AppColors.ink),
      (h: 104.0, c: AppColors.sage),
      (h: 130.0, c: AppColors.gold),
      (h: 98.0, c: Color(0xFF3D5A80)),
      (h: 116.0, c: Color(0xFFB23A48)),
    ];
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < spines.length; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 500 + i * 120),
              curve: Curves.easeOutBack,
              builder: (_, t, child) => Transform.translate(
                offset: Offset(0, (1 - t) * 60),
                child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
              ),
              child: Container(
                width: 30,
                height: spines[i].h,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: context.isDark && spines[i].c == AppColors.ink
                      ? const Color(0xFFF4EDE2)
                      : spines[i].c,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 3, width: 16, color: Colors.white54),
                    const SizedBox(height: 4),
                    Container(height: 3, width: 16, color: Colors.white54),
                  ],
                ),
              ),
            ),
          Transform.rotate(
            angle: -0.18,
            child: Container(
              width: 30,
              height: 108,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        selectedBackgroundColor: AppColors.accent,
        selectedForegroundColor: Colors.white,
      ),
      segments: const [
        ButtonSegment(value: 'uz', label: Text("O'z")),
        ButtonSegment(value: 'ru', label: Text('Ру')),
        ButtonSegment(value: 'en', label: Text('En')),
      ],
      selected: {settings.locale.languageCode},
      onSelectionChanged: (s) => settings.setLanguage(s.first),
    );
  }
}

class _ResetPasswordSheet extends StatefulWidget {
  const _ResetPasswordSheet({required this.initialEmail});
  final String initialEmail;

  @override
  State<_ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<_ResetPasswordSheet> {
  late final _email = TextEditingController(text: widget.initialEmail);
  final _key = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().sendPasswordReset(_email.text);
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, context.tr('reset_sent'));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
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
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('reset_title'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(context.tr('reset_body')),
            const SizedBox(height: 20),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: context.tr('email'),
                prefixIcon: const Icon(Icons.alternate_email_rounded),
              ),
              validator: Validators(context).email,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _send,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(context.tr('reset_send')),
            ),
          ],
        ),
      ),
    );
  }
}
