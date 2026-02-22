import 'package:flutter_test/flutter_test.dart';
import 'package:shoplifting_app/main.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that app title and dashboard overview show up
    expect(find.text('RetailLift'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
  });
}
