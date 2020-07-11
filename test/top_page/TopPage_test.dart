import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/constants.dart';
import 'package:proteinrecord/info_page/InfoPage.dart';
import 'package:proteinrecord/input_page/InputPage.dart';
import 'package:proteinrecord/main.dart';
import 'package:proteinrecord/monthly_page/MonthlyPage.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';
import 'package:proteinrecord/top_page/TopPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../TestApp.dart';
import '../data/dummy_data.dart';

/// TopPageのテスト
void main() {
  final testViewPortSize = Size(1080, 1776);

  /// テスト用の起動(ウィジェット単体テスト用)
  Widget testTopPage() {
    return TestApp(TopPage(
      date: "2020-02-01",
      todayCalendar: MockTodayCalendar(),
    ));
  }

  /// テスト用のアプリトップウィジェットから起動(画面遷移のテスト用)
  Widget testMyApp(String date) {
    return Provider<ProteinRecordRepository>(
        create: (context) => MockRecordRepository(),
        dispose: (context, bloc) => bloc.dispose(),
        child: MyApp(date: date));
  }

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  group('TopPageのテスト', () {
    setUpAll(() async {
      // チュートリアル表示済みにして、表示されないようにする
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.TUTORIAL_DONE: true});

      testSetupLocator(
          analyticsService: MockAnalyticsService(),
          versionCheckService: FalseMockVersionCheckService());
    });

    tearDownAll(() {
      cleanupLocator();
    });

    testWidgets('タイトルのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text(TopPage.TITLE_TOP), findsOneWidget);
    });

    testWidgets('メニューアイコン', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('PageViewのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('子としてMonthlyPageがいるかのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.byType(MonthlyPage), findsOneWidget);
    });

    testWidgets('左にスワイプできる', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年2月'), findsOneWidget);

      await tester.fling(find.byType(PageView), Offset(500.0, 0.0), 300);
      expect(find.text('2020年1月'), findsOneWidget);
    });

    testWidgets('右には最初はスワイプできない', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年2月'), findsOneWidget);

      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      expect(find.text('2020年2月'), findsOneWidget);
    });

    testWidgets('左、右にスワイプ', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testTopPage());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年2月'), findsOneWidget);
      await tester.fling(find.byType(PageView), Offset(500.0, 0.0), 300);
      expect(find.text('2020年1月'), findsOneWidget);

      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      expect(find.text('2020年2月'), findsOneWidget);
      expect(find.text('2020年1月'), findsNothing);
    });
  });

  group('画面遷移のテスト', () {
    final mockAnalytics = MockAnalyticsService();

    setUpAll(() async {
      // チュートリアル表示済みにして、表示されないようにする
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.TUTORIAL_DONE: true});

      testSetupLocator(
          analyticsService: mockAnalytics,
          versionCheckService: FalseMockVersionCheckService());
    });

    tearDownAll(() {
      cleanupLocator();
    });

    testWidgets('前月表示ボタン', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年2月'), findsOneWidget);
      // 左矢印アイコンタップ
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年1月'), findsOneWidget);
    });

    testWidgets('翌月表示ボタン', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年2月'), findsOneWidget);
      // 左矢印アイコンタップ
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle(); // ローディング終了を待つ
      // 右矢印アイコンタップ
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年1月'), findsNothing);
      expect(find.text('2020年2月'), findsOneWidget);
    });

    testWidgets('カレンダーセルのタップで入力画面に遷移', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      await tester.tap(find.byKey(Key('10')));
      await tester.pumpAndSettle(); // 遷移を待つ

      expect(find.byType(InputPage), findsOneWidget);
      expect(find.text('2020/02/05'), findsOneWidget);

      verify(mockAnalytics.sendCalendarEvent());

      // 戻るボタン(ActionBarアイコン)
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('情報アイコンタップで情報ページに遷移', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle(); // 遷移を待つ

      expect(find.byType(InfoPage), findsOneWidget);

      // 戻るボタン(ActionBarアイコン)
      expect(find.byType(BackButton), findsOneWidget);
    });
  });
}
