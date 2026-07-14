import 'package:flutter/material.dart';

import '../../../../core/constants/wialon_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';

/// Tarjeta con la identidad de la unidad consultada.
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.bg900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bg800),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(Spacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.35)),
            ),
            child: const AppImage(AppIcons.tire, color: AppColors.blueLight),
          ),
          Gap.hMd(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.title(WialonConstants.unitName),
                Gap.vXxs(),
                AppText.caption('ID ${WialonConstants.unitId} · GPS Wialon'),
              ],
            ),
          ),
          Gap.hSm(),
          const _LiveIndicator(),
        ],
      ),
    );
  }
}

/// Punto verde con anillo pulsante: la unidad reporta en vivo.
class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator();

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final double t = _controller.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo que se expande y desvanece.
                  Transform.scale(
                    scale: 1 + t * 1.4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success.withValues(
                            alpha: (1 - t) * 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Gap.vXxs(),
        const AppText.caption('En vivo', color: AppColors.text500),
      ],
    );
  }
}
