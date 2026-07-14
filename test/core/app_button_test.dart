import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilometer_check/core/widgets/widgets.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppButton', () {
    testWidgets('dispara onPressed al tocarlo', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(AppButton.filled(label: 'Consultar', onPressed: () => taps++)),
      );

      await tester.tap(find.text('Consultar'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('muestra loader y bloquea taps cuando isLoading', (
      tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          AppButton.filled(
            label: 'Consultar',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Consultar'), findsNothing);

      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      await tester.pump();

      expect(taps, 0, reason: 'isLoading debe evitar el doble tap');
    });
  });
}
