import 'package:flutter_test/flutter_test.dart';
import 'package:erp_software/main.dart';

void main() {
  testWidgets('ERP App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ErpApp());
    expect(find.byType(ErpApp), findsOneWidget);
  });
}
