import 'package:calculator/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calculator shows default result', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('0'), findsWidgets);
    expect(find.text('='), findsOneWidget);
  });
}
