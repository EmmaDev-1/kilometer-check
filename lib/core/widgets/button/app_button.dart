import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../spacing/spacing_tokens.dart';

enum _AppButtonVariant { filled, outlined }

/// Botón reutilizable de la app.
///
/// Variantes: [AppButton.filled] (primario) y [AppButton.outlined]
/// (secundario/alternativo). Soporta ícono izquierdo ([leading]),
/// derecho ([trailing]) y estado de carga ([isLoading], que además
/// bloquea el doble tap durante peticiones).
///
/// Incluye una micro-animación de escala al presionar y un
/// `AnimatedSwitcher` entre contenido y loader.
class AppButton extends StatefulWidget {
  const AppButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.expanded = true,
  }) : _variant = _AppButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.expanded = true,
  }) : _variant = _AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;

  /// Si es `true`, el botón ocupa todo el ancho disponible.
  final bool expanded;

  final _AppButtonVariant _variant;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  Widget _content(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        key: ValueKey('loader'),
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.text100,
        ),
      );
    }

    return Row(
      key: const ValueKey('content'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: Spacing.xs),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: Spacing.xs),
          widget.trailing!,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final ButtonStyle style =
        switch (widget._variant) {
          _AppButtonVariant.filled => FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            disabledBackgroundColor: scheme.primary.withValues(alpha: 0.55),
            disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.8),
          ),
          _AppButtonVariant.outlined => OutlinedButton.styleFrom(
            foregroundColor: AppColors.text100,
            side: const BorderSide(color: AppColors.bg700),
          ),
        }.copyWith(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: Spacing.lg),
          ),
        );

    final Widget switcher = AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.easeInOut,
      switchOutCurve: AppMotion.easeInOut,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: _content(context),
    );

    final VoidCallback? onPressed = _enabled ? widget.onPressed : null;

    final Widget button = switch (widget._variant) {
      _AppButtonVariant.filled => FilledButton(
        style: style,
        onPressed: onPressed,
        child: switcher,
      ),
      _AppButtonVariant.outlined => OutlinedButton(
        style: style,
        onPressed: onPressed,
        child: switcher,
      ),
    };

    return AnimatedScale(
      scale: _pressed && _enabled ? 0.97 : 1,
      duration: AppMotion.fast,
      curve: AppMotion.easeOut,
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: widget.expanded
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}
