// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gennextapp/main.dart';

void main() {
  testWidgets('Signin Page Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // await tester.enterText(find.byKey(ValueKey("Username")), 'username');
    // await tester.enterText(find.byKey(ValueKey("Password")), 'password');
    // await tester.pump(Duration(milliseconds: 300));

    // expect(find.byKey(ValueKey('button'), skipOffstage: false), findsOneWidget);
    // await tester.tap(find.byKey(ValueKey('button'), skipOffstage: false));

    // await tester.pump();
  });
}
