import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('GenNext App', () {
    final usernameFinder = find.byValueKey('Username');
    final passwordFinder = find.byValueKey('Password');
    final buttonFinder = find.byValueKey('button');
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Sign in test', () async {
      await driver.tap(usernameFinder);
      await driver.enterText('chandra');
      await driver.tap(passwordFinder);
      await driver.enterText('gennext123');
      await driver.tap(buttonFinder);

      await driver.waitFor(find.text('Upcoming Sessions'));
    });
  });
}
