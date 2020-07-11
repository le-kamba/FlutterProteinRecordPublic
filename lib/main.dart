import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proteinrecord/info_page/InfoPage.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'data/ProteinRecord.dart';
import 'data/database.dart';
import 'input_page/InputPage.dart';
import 'repository/PackageInfoRepository.dart';
import 'repository/ProteinRecordRepository.dart';
import 'services/AnalyticsService.dart';
import 'services/NavigationService.dart';
import 'services/VersionCheckService.dart';
import 'top_page/TopPage.dart';
import 'tutorial_page/TutorialPage.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  locator
      .registerLazySingleton<VersionCheckService>(() => VersionCheckService());
}

void main() async {
  setupLocator();

  // Hiveの初期化
  await Hive.initFlutter();
  Hive.registerAdapter(RecordModelAdapter());

  // 描画の開始
  runApp(Provider<ProteinRecordRepository>(
    create: (context) => ProteinRecordRepository(RecordModelBox()),
    dispose: (context, bloc) => bloc.dispose(),
    child: MyApp(),
  ));
}

/// アプリのルートウィジェット
class MyApp extends StatelessWidget {
  MyApp({Key key, this.date}) : super();

  final String date;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 日本語フォント設定
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ja', ''), // Japanese
      ],
      // Navigator
      navigatorKey: locator<NavigationService>().navigatorKey,
      navigatorObservers: [
        AnalyticsService.observer,
      ],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RoutePathName.INDEX:
            {
              var launchDate =
                  date ?? ProteinRecord.formatDateTimeToRecord(DateTime.now());
              return MaterialPageRoute(
                  settings: RouteSettings(name: PageName.TOP),
                  builder: (context) => TopPage(date: launchDate));
            }
          case RoutePathName.INPUT:
            final ProteinRecord record = settings.arguments;
            return MaterialPageRoute(
                settings: RouteSettings(name: PageName.INPUT),
                builder: (context) => InputPage(record: record));
          case RoutePathName.TUTORIAL:
            return MaterialPageRoute(
                settings: RouteSettings(name: PageName.TUTORIAL),
                builder: (context) => TutorialPage());
            break;
          case RoutePathName.INFO:
            return MaterialPageRoute(
                settings: RouteSettings(name: PageName.INFO),
                builder: (context) =>
                    InfoPage(packageInfoRepository: PackageInfoRepository()));
            break;
//          case '/detail':
//            break;
          default:
            return MaterialPageRoute(
                builder: (context) => Scaffold(
                      body: Center(
                        child: Text('No path for ${settings.name}'),
                      ),
                    ));
        }
      },
      initialRoute: RoutePathName.INDEX,
      // 画面
      title: 'たんぱく録',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
