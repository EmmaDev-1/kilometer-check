import 'package:flutter/material.dart';

/// Paleta de la marca iTire (extraída de itire.com.mx).
final class AppColors {
  const AppColors._();

  // Marca
  static const Color blue = Color(0xFF005CA8);
  static const Color blueLight = Color(0xFF0070CC);
  static const Color blueGlow = Color(0x59005CA8); // 35% alpha
  static const Color yellow = Color(0xFFECB806);
  static const Color yellowLight = Color(0xFFFFE42C);

  // Fondos (dark)
  static const Color bg950 = Color(0xFF0A0A0A);
  static const Color bg900 = Color(0xFF171717);
  static const Color bg800 = Color(0xFF262626);
  static const Color bg700 = Color(0xFF404040);

  // Texto
  static const Color text100 = Color(0xFFFAFAFA);
  static const Color text300 = Color(0xFFD4D4D4);
  static const Color text500 = Color(0xFF737373);

  // Semánticos
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
}
