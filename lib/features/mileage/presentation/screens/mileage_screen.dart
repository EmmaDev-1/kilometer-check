import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/mileage_provider.dart';
import '../widgets/mileage_status_message.dart';
import '../widgets/mileage_trend_badge.dart';
import '../widgets/odometer_display.dart';
import '../widgets/vehicle_card.dart';

/// Pantalla principal: el encargado de flotilla consulta el kilometraje
/// actualizado de la unidad con el botón "Consultar kilometraje".
///
/// Lee y reacciona al estado exclusivamente a través de [MileageProvider].
class MileageScreen extends StatelessWidget {
  const MileageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MileageProvider provider = context.watch<MileageProvider>();

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          const _BackgroundGlow(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Entrance(index: 0, child: _BrandHeader()),
                Gap.vLg(),
                const Entrance(index: 1, child: VehicleCard()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Entrance(
                        index: 2,
                        child: Column(
                          children: [
                            OdometerDisplay(
                              kilometers: provider.reading?.kilometers,
                              isLoading: provider.isLoading,
                            ),
                            Gap.vLg(),
                            MileageTrendBadge(
                              trend: provider.trend,
                              deltaKm: provider.deltaKm,
                            ),
                            Gap.vMd(),
                            MileageStatusMessage(
                              status: provider.status,
                              lastUpdate: provider.reading?.timestamp,
                              errorMessage: provider.errorMessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Entrance(
                  index: 3,
                  child: AnimatedBackgroundButton(
                    label: 'Consultar kilometraje',
                    leading: const Icon(Icons.refresh_rounded, size: 20),
                    isLoading: provider.isLoading,
                    // El fondo animado de círculos se movió a la tarjeta del
                    // contador (OdometerDisplay). Para revertir: `animated: true`.
                    animated: false,
                    onPressed: () =>
                        context.read<MileageProvider>().fetchMileage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Identidad de marca en la parte superior de la pantalla.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const AppImage(AppIcons.tire, color: AppColors.yellow),
        ),
        Gap.hSm(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.redHatDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text100,
                ),
                children: const [
                  TextSpan(
                    text: 'i',
                    style: TextStyle(color: AppColors.yellow),
                  ),
                  TextSpan(text: 'Tire'),
                ],
              ),
            ),
            const AppText.caption('Monitor de flotilla'),
          ],
        ),
      ],
    );
  }
}

/// Halos decorativos de fondo (azul arriba, tenue abajo), sin
/// interceptar toques.
class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -100,
            child: _glowCircle(AppColors.blue.withValues(alpha: 0.16), 320),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _glowCircle(AppColors.blue.withValues(alpha: 0.08), 340),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
