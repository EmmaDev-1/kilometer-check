import 'package:flutter/material.dart';

import '../../utils/typography/text_styles.dart';

enum _AppTextPreset { custom, body, title, caption, headline }

/// Widget de texto unificado con presets tipográficos de [AppTextStyles].
///
/// Presets: `AppText.body`, `AppText.title`, `AppText.caption`,
/// `AppText.headline`. Para estilos puntuales usa el constructor custom.
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
  }) : _preset = _AppTextPreset.custom;

  const AppText.body(
    this.text, {
    super.key,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
  }) : _preset = _AppTextPreset.body,
       style = null;

  const AppText.title(
    this.text, {
    super.key,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
  }) : _preset = _AppTextPreset.title,
       style = null;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
  }) : _preset = _AppTextPreset.caption,
       style = null;

  const AppText.headline(
    this.text, {
    super.key,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
  }) : _preset = _AppTextPreset.headline,
       style = null;

  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final _AppTextPreset _preset;

  TextStyle _resolveStyle(BuildContext context) {
    final TextStyle base = switch (_preset) {
      _AppTextPreset.body => AppTextStyles.body(context),
      _AppTextPreset.title => AppTextStyles.title(context),
      _AppTextPreset.caption => AppTextStyles.caption(context),
      _AppTextPreset.headline => AppTextStyles.headline(context),
      _AppTextPreset.custom => style ?? AppTextStyles.body(context),
    };
    return color != null ? base.copyWith(color: color) : base;
  }

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: _resolveStyle(context),
    maxLines: maxLines,
    textAlign: textAlign,
    overflow: overflow,
  );
}
