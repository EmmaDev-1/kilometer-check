import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Raíz de la aplicación: tema iTire + navegación con Go Router.
class KilometerCheckApp extends StatelessWidget {
  const KilometerCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'iTire Kilometraje',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
