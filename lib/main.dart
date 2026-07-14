import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'features/mileage/data/datasources/wialon_remote_datasource.dart';
import 'features/mileage/data/repositories/mileage_repository_impl.dart';
import 'features/mileage/domain/repositories/mileage_repository.dart';
import 'features/mileage/domain/usecases/get_current_mileage.dart';
import 'features/mileage/presentation/providers/mileage_provider.dart';

void main() {
  runApp(const AppBootstrap());
}

/// Composición de dependencias (DI) con `provider`:
/// cliente HTTP → datasource → repositorio → caso de uso → ChangeNotifier.
///
/// Las pantallas solo conocen [MileageProvider]; el resto de capas queda
/// oculto detrás de sus contratos (fácil de sustituir en pruebas).
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),
        Provider<WialonRemoteDatasource>(
          create: (context) => WialonRemoteDatasource(client: context.read()),
        ),
        Provider<MileageRepository>(
          create: (context) =>
              MileageRepositoryImpl(context.read<WialonRemoteDatasource>()),
        ),
        Provider<GetCurrentMileage>(
          create: (context) =>
              GetCurrentMileage(context.read<MileageRepository>()),
        ),
        ChangeNotifierProvider<MileageProvider>(
          create: (context) =>
              MileageProvider(getCurrentMileage: context.read()),
        ),
      ],
      child: const KilometerCheckApp(),
    );
  }
}
