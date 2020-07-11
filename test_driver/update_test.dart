import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'TestUtils.dart';

void main() {
  group('App Driver Test', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('同意ダイアログ', () async {
      final health = await driver.checkHealth();
      print(health.status);

      await driver.waitFor(find.byValueKey('policy dialog'));

      await takeScreenShot(driver, 'policy_dialog');
    });

    test('更新ダイアログ', () async {
      final health = await driver.checkHealth();
      print(health.status);

      await driver.tap(find.text('同意する'));

      await takeScreenShot(driver, 'update_dialog');
    });
  });
}
