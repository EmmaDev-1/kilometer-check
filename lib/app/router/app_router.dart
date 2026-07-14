import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_motion.dart';
import '../../features/mileage/presentation/screens/mileage_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

/// Configuración de navegación de la app (Go Router).
///
/// `/` (splash) → `/home` con transición fade + scale sutil.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashPath,
  routes: [
    GoRoute(
      path: AppRoutes.splashPath,
      name: AppRoutes.splashName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.homePath,
      name: AppRoutes.homeName,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const MileageScreen(),
        transitionDuration: AppMotion.slow,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: AppMotion.easeOut,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    ),
  ],
);
