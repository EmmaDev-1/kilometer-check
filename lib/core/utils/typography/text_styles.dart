import 'package:flutter/material.dart';

/// Estilos de texto base acoplados a `Theme.of(context).textTheme`
/// para respetar la configuración visual global.
///
/// Preferir `AppText` (en `core/widgets`) para casos comunes de UI;
/// usar `AppTextStyles` directo solo para `Text` custom.
final class AppTextStyles {
  const AppTextStyles._();

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);

  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium ??
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);

  static TextStyle headline(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium ??
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
}
