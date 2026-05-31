import 'package:flutter_test/flutter_test.dart';
import 'package:contact_info/main.dart';

void main() {
  testWidgets('App launches successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ContactsApp());

    // Verify splash screen or initial elements render without crashing
    expect(find.byType(ContactsApp), findsOneWidget);
  });
}
