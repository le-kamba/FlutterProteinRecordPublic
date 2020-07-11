import 'package:flutter/material.dart';
import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proteinrecord/constants.dart';
import 'package:proteinrecord/main.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';
import 'package:proteinrecord/top_page/TopPage.dart';
import 'package:proteinrecord/tutorial_page/TutorialPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../TestApp.dart';
import '../data/dummy_data.dart';

/// TutorialPageのテスト
void main() {
  final testViewPortSize = Size(1080, 1776);

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  /// テスト用の起動(ウィジェット単体テスト用)
  Widget testTopPage() {
    return TestApp(TutorialPage());
  }

  /// テスト用のアプリトップウィジェットから起動(画面遷移のテスト用)
  /// Topページに戻るテストがあるので、アプリのルートから起動が必要
  Widget testMyApp(String date) {
    return Provider<ProteinRecordRepository>(
        create: (context) => MockRecordRepository(),
        dispose: (context, bloc) => bloc.dispose(),
        child: MyApp(date: date));
  }

  group('TutorialPageのテスト', () {
    setUpAll(() async {
      testSetupLocator(
          analyticsService: MockAnalyticsService(),
          versionCheckService: FalseMockVersionCheckService());
    });

    tearDownAll(() {
      cleanupLocator();
    });

    testWidgets('SlidingTutorialのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      WidgetPredicate predicate =
          (Widget widget) => widget is SlidingTutorial && widget.pageCount == 4;

      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('SlidingIndicatorのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.byType(SlidingIndicator), findsOneWidget);

      // アクティブなインジケーター数1
      expect(findByAssetImage('assets/tutorial/dot1.png'), findsOneWidget);
      // 非アクティブなインジケーター数(アクティブなのも裏にいるらしいので4)
      expect(findByAssetImage('assets/tutorial/dot2.png'), findsNWidgets(4));
    });

    testWidgets('PageViewのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.byType(PageView), findsOneWidget);

      // 背景色の確認
      final predicate = (Widget widget) =>
          widget is Scaffold &&
          widget.backgroundColor == tutorialBackgroundColor;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('右にスワイプできる', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ
      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial1.png'), findsOneWidget);
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial2.png'), findsOneWidget);
    });

    testWidgets('左には最初はスワイプできない', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial1.png'), findsOneWidget);

      await tester.fling(find.byType(PageView), Offset(500.0, 0.0), 300);
      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial1.png'), findsOneWidget);
    });

    testWidgets('右、左にスワイプ', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial1.png'), findsOneWidget);
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial2.png'), findsOneWidget);

      await tester.fling(find.byType(PageView), Offset(500.0, 0.0), 300);
      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial1.png'), findsOneWidget);
      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial2.png'), findsNothing);
    });

    testWidgets('最後までスワイプ', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // 最初のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial1.png'), findsOneWidget);
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle(); // ローディング終了を待つ
      // 次のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial2.png'), findsOneWidget);

      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      // 次のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial3.png'), findsOneWidget);
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      // 次のページの画像
      expect(findByAssetImage('assets/tutorial/tutorial4.png'), findsOneWidget);
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      // 最後から変わらない
      expect(findByAssetImage('assets/tutorial/tutorial4.png'), findsOneWidget);
    });
  });

  group('画面遷移のテスト', () {
    final mockAnalytics = MockAnalyticsService();

    setUpAll(() async {
      testSetupLocator(
          analyticsService: mockAnalytics,
          versionCheckService: FalseMockVersionCheckService());
    });

    tearDownAll(() {
      cleanupLocator();
    });

    setUp(() {
      // チュートリアルが表示されるようにする
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.TUTORIAL_DONE: false});
    });

    testWidgets('途中ページではタップしても何も起きない', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text(TopPage.TITLE_TOP), findsNothing);

      // タップ
      var finder = findByAssetImage('assets/tutorial/tutorial1.png');
      await tester.tap(finder);
      expect(find.text(TopPage.TITLE_TOP), findsNothing);

      // 次ページまでスワイプ
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      // タップ
      finder = findByAssetImage('assets/tutorial/tutorial2.png');
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(find.text(TopPage.TITLE_TOP), findsNothing);

      // 次ページまでスワイプ
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      // タップ
      finder = findByAssetImage('assets/tutorial/tutorial3.png');
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(find.text(TopPage.TITLE_TOP), findsNothing);
    });

    testWidgets('最終ページまで遷移してタップ', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text(TopPage.TITLE_TOP), findsNothing);

      // 最後のページまでスワイプ
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();

      // タップ
      await tester.tap(find.byKey(Key('tutorialLastPage')));
      await tester.pumpAndSettle();

      expect(find.text(TopPage.TITLE_TOP), findsOneWidget);
    });
  });
}
