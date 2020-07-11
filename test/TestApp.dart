import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proteinrecord/main.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';
import 'package:proteinrecord/services/AnalyticsService.dart';
import 'package:proteinrecord/services/NavigationService.dart';
import 'package:proteinrecord/services/VersionCheckService.dart';
import 'package:provider/provider.dart';

import 'data/dummy_data.dart';

/// Test用のMaterialApp起動用クラス
/// Mockリポジトリクラスなどを使用しています
class TestApp extends StatelessWidget {
  TestApp(this.widget);

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Provider<ProteinRecordRepository>(
      create: (context) => MockRecordRepository(),
      dispose: (context, bloc) => bloc.dispose(),
      child: MaterialApp(
        // 日本語フォント設定
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ja', ''), // Japanese
        ],
        home: widget,
      ),
    );
  }
}

/// テスト用のget_it Locator初期化
void testSetupLocator(
    {@required AnalyticsService analyticsService,
    @required VersionCheckService versionCheckService}) {
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<AnalyticsService>(analyticsService);
  locator.registerSingleton<VersionCheckService>(versionCheckService);
}

void cleanupLocator() {
  locator.unregister<NavigationService>();
  locator.unregister<AnalyticsService>();
  locator.unregister<VersionCheckService>();
}

/// 指定のpathを表示しているAssetImageを見つける
Finder findByAssetImage(String path) {
  final finder = find.byWidgetPredicate((Widget widget) {
    if (widget is Image && widget.image is AssetImage) {
      final assetImage = widget.image as AssetImage;
      return assetImage.keyName == path;
    }
    return false;
  });
  return finder;
}
