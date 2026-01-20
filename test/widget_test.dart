
import 'package:flutter_test/flutter_test.dart';
import 'package:shoplifting_app/main.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShopliftingApp());

    // Verify that dashboard shows up
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
  });
}
