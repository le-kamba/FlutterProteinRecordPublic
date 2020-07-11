import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> takeScreenShot(FlutterDriver driver, String filename) async {
  await driver.waitUntilNoTransientCallbacks();
  final pixels = await driver.screenshot();

  final file = File('./test_driver/screenshots/$filename.png');
  await file.writeAsBytes(pixels);
  print('wrote $file');
}
