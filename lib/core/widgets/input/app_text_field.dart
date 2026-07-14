import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../spacing/spacing_tokens.dart';

/// Campo de texto reutilizable con decoración estándar
/// (fill, bordes redondeados, hint, padding).
///
/// Para diseños específicos sobreescribe `fillColor`, `borderColor` y
/// `focusedBorderColor`. Activa `animatedLabel` para el efecto de
/// label flotante (hint dentro → label arriba al enfocar).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.animatedLabel = false,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? hintText;

  /// Si es `true`, el hint se comporta como label flotante.
  final bool animatedLabel;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.text100),
      decoration: InputDecoration(
        hintText: animatedLabel ? null : hintText,
        labelText: animatedLabel ? hintText : null,
        floatingLabelBehavior: animatedLabel
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.never,
        hintStyle: const TextStyle(color: AppColors.text500),
        labelStyle: const TextStyle(color: AppColors.text500),
        floatingLabelStyle: TextStyle(
          color: focusedBorderColor ?? scheme.primary,
        ),
        filled: true,
        fillColor: fillColor ?? AppColors.bg900,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        enabledBorder: _border(borderColor ?? AppColors.bg800),
        focusedBorder: _border(focusedBorderColor ?? scheme.primary),
        disabledBorder: _border(AppColors.bg800.withValues(alpha: 0.5)),
        errorBorder: _border(scheme.error),
        focusedErrorBorder: _border(scheme.error),
      ),
    );
  }
}
