import 'package:flutter_test/flutter_test.dart';
import 'package:smarth_growth/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartGrowthApp());
    expect(find.text('SmartGrowth'), findsOneWidget);
  });
}
