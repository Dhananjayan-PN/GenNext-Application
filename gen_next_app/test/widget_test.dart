import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gennextapp/main.dart';

void main() {
  testWidgets('Signin Page Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsNothing);

    await tester.enterText(find.byKey(Key("Username")), 'chandra');
    await tester.enterText(find.byKey(Key("Password")), 'gennext');
    await tester.pump();
  });
}
