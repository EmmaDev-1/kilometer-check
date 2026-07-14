import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/mileage_provider.dart';

/// Leyenda EXTRA del ejercicio: informa si el kilometraje aumentó o se
/// mantuvo constante respecto a la consulta anterior.
class MileageTrendBadge extends StatelessWidget {
  const MileageTrendBadge({
    super.key,
    required this.trend,
    required this.deltaKm,
  });

  final MileageTrend trend;
  final int deltaKm;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.base,
      switchInCurve: AppMotion.easeOut,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: switch (trend) {
        MileageTrend.none => const SizedBox.shrink(key: ValueKey('none')),
        MileageTrend.firstReading => const _Badge(
          key: ValueKey('first'),
          icon: Icons.flag_rounded,
          color: AppColors.blueLight,
          label: 'Primera lectura registrada',
        ),
        MileageTrend.increased => _Badge(
          key: const ValueKey('increased'),
          icon: Icons.trending_up_rounded,
          color: AppColors.yellow,
          label:
              'El kilometraje aumentó '
              '+${NumberFormatter.thousands(deltaKm)} km',
        ),
        MileageTrend.constant => const _Badge(
          key: ValueKey('constant'),
          icon: Icons.trending_flat_rounded,
          color: AppColors.blueLight,
          label: 'El kilometraje se ha mantenido constante',
        ),
        MileageTrend.decreased => _Badge(
          key: const ValueKey('decreased'),
          icon: Icons.trending_down_rounded,
          color: AppColors.text500,
          label:
              'El contador disminuyó '
              '${NumberFormatter.thousands(deltaKm)} km',
        ),
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          Gap.hXs(),
          Flexible(
            child: AppText.body(label, color: AppColors.text100, maxLines: 2),
          ),
        ],
      ),
    );
  }
}
