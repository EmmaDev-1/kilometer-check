import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/mileage_provider.dart';

/// Feedback del estado de la llamada a Wialon:
/// hint inicial, progreso, hora de la última actualización o error.
class MileageStatusMessage extends StatelessWidget {
  const MileageStatusMessage({
    super.key,
    required this.status,
    required this.lastUpdate,
    required this.errorMessage,
  });

  final MileageStatus status;
  final DateTime? lastUpdate;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.base,
      curve: AppMotion.easeInOut,
      child: AnimatedSwitcher(
        duration: AppMotion.base,
        switchInCurve: AppMotion.easeOut,
        child: switch (status) {
          MileageStatus.initial => _InfoRow(
            key: const ValueKey('initial'),
            child: const AppText.caption(
              'Presiona el botón para obtener la lectura más reciente.',
              textAlign: TextAlign.center,
            ),
          ),
          MileageStatus.loading => _InfoRow(
            key: const ValueKey('loading'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                Gap.hXs(),
                const AppText.caption('Consultando kilometraje en Wialon…'),
              ],
            ),
          ),
          MileageStatus.success => _InfoRow(
            key: ValueKey('success-${lastUpdate?.millisecondsSinceEpoch}'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: AppColors.success,
                ),
                Gap.hXs(),
                AppText.caption(
                  'Última actualización: '
                  '${lastUpdate != null ? TimeFormatter.hms(lastUpdate!) : '—'}',
                ),
              ],
            ),
          ),
          MileageStatus.failure => Container(
            key: const ValueKey('failure'),
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.40),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: AppColors.danger,
                ),
                Gap.hXs(),
                Expanded(
                  child: AppText.body(
                    errorMessage ?? 'Ocurrió un error inesperado.',
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(child: child);
}
