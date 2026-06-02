import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sun_pos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots and shows splash with Sun POS branding', (
    tester,
  ) async {
    app.main();

    // main() is async (locale init, AppInfoHelper). Pump in small slices
    // until runApp has scheduled the first real frame.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Sun POS').evaluate().isNotEmpty) break;
    }

    expect(find.text('Sun POS'), findsOneWidget);
    expect(find.text('Point of Sale System'), findsOneWidget);
  });
}
