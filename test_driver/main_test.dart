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

    test('チュートリアル1', () async {
      final health = await driver.checkHealth();
      print(health.status);

      await takeScreenShot(driver, 'tutorial1');
    });

    test('チュートリアル2', () async {
      final health = await driver.checkHealth();
      print(health.status);
      final finder = find.byType('PageView');
      await driver.scroll(finder, -500, 0, Duration(milliseconds: 200));
      await driver.waitFor(finder);

      await takeScreenShot(driver, 'tutorial2');
    });

    test('チュートリアル3', () async {
      final health = await driver.checkHealth();
      print(health.status);
      final finder = find.byType('PageView');
      await driver.scroll(finder, -500, 0, Duration(milliseconds: 200));
      await driver.waitFor(finder);

      await takeScreenShot(driver, 'tutorial3');
    });

    test('チュートリアル4', () async {
      final health = await driver.checkHealth();
      print(health.status);
      final finder = find.byType('PageView');
      await driver.scroll(finder, -500, 0, Duration(milliseconds: 200));
      await driver.waitFor(finder);

      await takeScreenShot(driver, 'tutorial4');
    });

    test('カレンダー', () async {
      final health = await driver.checkHealth();
      print(health.status);

      // チュートリアル終了画面でタップ
      await driver.tap(find.byValueKey('tutorialLastPage'));

      await takeScreenShot(driver, 'calendar');
    });

    test('情報ページ', () async {
      final health = await driver.checkHealth();
      print(health.status);

      final icon = find.byValueKey('info icon');
      await driver.waitFor(icon);
      await driver.tap(icon);

      final label = find.text('規約とプライバシーポリシー');
      await driver.waitFor(label);

      await takeScreenShot(driver, 'info_page');
      await driver.tap(find.byTooltip('戻る'));
    });

    test('入力画面', () async {
      final health = await driver.checkHealth();
      print(health.status);

      final cell = find.byValueKey('10');
      await driver.waitFor(cell);
      await driver.tap(cell);

      final card = find.byValueKey('MajorType.MEAT');
      await driver.waitFor(card);

      await takeScreenShot(driver, 'input_page');
    });

    test('削除確認', () async {
      final health = await driver.checkHealth();
      print(health.status);

      final icon = find.byValueKey('delete icon');
      await driver.waitFor(icon);
      await driver.tap(icon);

      final dialog = find.byType('AlertDialog');
      await driver.waitFor(dialog);

      await takeScreenShot(driver, 'delete_dialog');

      // 閉じる
      await driver.tap(find.text('Cancel'));

      // 戻る
      await driver.tap(find.byTooltip('戻る'));
    });
  });
}
