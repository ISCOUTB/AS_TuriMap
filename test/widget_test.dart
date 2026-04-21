import 'package:flutter_test/flutter_test.dart';
import 'package:turimap/main.dart';

void main() {
  testWidgets('TuriMap smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TuriMapApp());
    expect(find.byType(TuriMapApp), findsOneWidget);
  });
}