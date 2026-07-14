import 'package:flutter/widgets.dart';

import 'spacing_tokens.dart';

/// Espaciador consistente basado en [SizedBox].
///
/// - Usa `Gap.v*` dentro de `Column`.
/// - Usa `Gap.h*` dentro de `Row`.
class Gap extends StatelessWidget {
  const Gap.v(this.size, {super.key}) : _vertical = true;
  const Gap.h(this.size, {super.key}) : _vertical = false;

  final double size;
  final bool _vertical;

  // Presets verticales.
  static Gap vXxs() => const Gap.v(Spacing.xxs);
  static Gap vXs() => const Gap.v(Spacing.xs);
  static Gap vSm() => const Gap.v(Spacing.sm);
  static Gap vMd() => const Gap.v(Spacing.md);
  static Gap vLg() => const Gap.v(Spacing.lg);
  static Gap vXl() => const Gap.v(Spacing.xl);
  static Gap vXxl() => const Gap.v(Spacing.xxl);

  // Presets horizontales.
  static Gap hXxs() => const Gap.h(Spacing.xxs);
  static Gap hXs() => const Gap.h(Spacing.xs);
  static Gap hSm() => const Gap.h(Spacing.sm);
  static Gap hMd() => const Gap.h(Spacing.md);
  static Gap hLg() => const Gap.h(Spacing.lg);
  static Gap hXl() => const Gap.h(Spacing.xl);
  static Gap hXxl() => const Gap.h(Spacing.xxl);

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: _vertical ? null : size, height: _vertical ? size : null);
}
