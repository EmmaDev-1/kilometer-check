import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema global de la app, alineado a la identidad de iTire:
/// modo oscuro, azul primario, amarillo de acento y tipografías
/// Red Hat Display (display) + Inter (cuerpo) + JetBrains Mono (datos).
final class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final ColorScheme colorScheme = const ColorScheme.dark(
      primary: AppColors.blue,
      onPrimary: AppColors.text100,
      secondary: AppColors.yellow,
      onSecondary: AppColors.bg950,
      surface: AppColors.bg950,
      onSurface: AppColors.text300,
      surfaceContainer: AppColors.bg900,
      outline: AppColors.bg700,
      error: AppColors.danger,
    );

    final TextTheme baseText = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    final TextTheme textTheme = baseText.copyWith(
      // Display / headlines con Red Hat Display.
      displayLarge: GoogleFonts.redHatDisplay(
        textStyle: baseText.displayLarge,
        fontWeight: FontWeight.w800,
        color: AppColors.text100,
      ),
      headlineLarge: GoogleFonts.redHatDisplay(
        textStyle: baseText.headlineLarge,
        fontWeight: FontWeight.w800,
        color: AppColors.text100,
      ),
      headlineMedium: GoogleFonts.redHatDisplay(
        textStyle: baseText.headlineMedium,
        fontWeight: FontWeight.w700,
        color: AppColors.text100,
      ),
      titleLarge: GoogleFonts.redHatDisplay(
        textStyle: baseText.titleLarge,
        fontWeight: FontWeight.w700,
        color: AppColors.text100,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.text100,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(color: AppColors.text300),
      bodySmall: baseText.bodySmall?.copyWith(color: AppColors.text500),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg950,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.text100,
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: const DividerThemeData(color: AppColors.bg800),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.yellow,
      ),
    );
  }
}
