import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sign In Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsNothing);

    await tester.enterText(find.byKey(Key("Username")), 'chandra');
    await tester.enterText(find.byKey(Key("Password")), 'gennext');

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byKey(Key("Sign In Button")));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('Hello'), findsNothing);
    expect(find.text('Hey'), findsOneWidget);
  });
}
