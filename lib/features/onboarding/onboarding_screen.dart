import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../state/settings_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  double _page = 0;

  static const _pages = [
    (emoji: '📚', title: 'ob1_title', body: 'ob1_body', color: AppColors.accent),
    (emoji: '🌙', title: 'ob2_title', body: 'ob2_body', color: Color(0xFF3D5A80)),
    (emoji: '🎯', title: 'ob3_title', body: 'ob3_body', color: AppColors.sage),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.read<SettingsProvider>().completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final index = _page.round();
    final isLast = index == _pages.length - 1;
    final color = Color.lerp(
      _pages[_page.floor().clamp(0, _pages.length - 1)].color,
      _pages[_page.ceil().clamp(0, _pages.length - 1)].color,
      _page - _page.floor(),
    )!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(context.tr('ob_skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  final offset = (_page - i).clamp(-1.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(offset * 80, 0),
                          child: _Illustration(emoji: p.emoji, color: p.color),
                        ),
                        const SizedBox(height: 48),
                        Opacity(
                          opacity: 1 - offset.abs(),
                          child: Column(
                            children: [
                              Text(
                                context.tr(p.title),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                context.tr(p.body),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: context.colors.onSurface
                                      .withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Row(
                    children: List.generate(_pages.length, (i) {
                      final active = (i - _page).abs() < 0.5;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? color
                              : context.colors.onSurface.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 160,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: color),
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              ),
                      child: Text(
                        context.tr(isLast ? 'ob_start' : 'ob_next'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Emoji atrofida aylanib turuvchi "kitob" bloklari.
class _Illustration extends StatefulWidget {
  const _Illustration({required this.emoji, required this.color});
  final String emoji;
  final Color color;

  @override
  State<_Illustration> createState() => _IllustrationState();
}

class _IllustrationState extends State<_Illustration>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.12),
                ),
              ),
              for (var i = 0; i < 5; i++)
                Transform.translate(
                  offset: Offset(
                    math.cos(t + i * 2 * math.pi / 5) * 105,
                    math.sin(t + i * 2 * math.pi / 5) * 105,
                  ),
                  child: Transform.rotate(
                    angle: t + i,
                    child: Container(
                      width: 22,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.35 + i * 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              Container(
                width: 130,
                height: 130,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Text(widget.emoji, style: const TextStyle(fontSize: 60)),
              ),
            ],
          );
        },
      ),
    );
  }
}
