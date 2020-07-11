import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/constants.dart';
import 'package:proteinrecord/main.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';
import 'package:proteinrecord/top_page/Updater.dart';
import 'package:proteinrecord/tutorial_page/TutorialPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../TestApp.dart';
import '../data/dummy_data.dart';

/// Updaterウィジェットのテスト
void main() {
  final testViewPortSize = Size(1080, 1776);
  final mockTodayCalendar = MockTodayCalendar();
  final mockVersionCheck = MockVersionCheckService();

  /// テスト用の起動
  Widget testUpdater() {
    return TestApp(Updater(todayCalendar: mockTodayCalendar));
  }

  /// テスト用のアプリトップウィジェットから起動(画面遷移のテスト用)
  /// Topページに戻るテストがあるので、アプリのルートから起動が必要
  Widget testMyApp(String date) {
    return Provider<ProteinRecordRepository>(
        create: (context) => MockRecordRepository(),
        dispose: (context, bloc) => bloc.dispose(),
        child: MyApp(date: date));
  }

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  group('ダイアログの表示制御テスト', () {
    setUpAll(() async {
      testSetupLocator(
          analyticsService: MockAnalyticsService(),
          versionCheckService: mockVersionCheck);
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(true));
    });

    tearDownAll(() {
      cleanupLocator();
    });

    testWidgets('更新ダイアログ表示', (WidgetTester tester) async {
      when(mockVersionCheck.needUpdate).thenReturn(true);
      when(mockVersionCheck.needPolicyAgreement).thenReturn(false);

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ているかのチェック
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('バージョン更新のお知らせ'), findsOneWidget);
      expect(find.byKey(Key('update dialog')), findsOneWidget);
      expect(find.text('新しいバージョンのアプリが利用可能です。ストアより更新版を入手して、ご利用下さい。'),
          findsOneWidget);

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.data == '今すぐ更新' &&
              widget.style == TextStyle(color: Colors.red)),
          findsOneWidget);
    });

    testWidgets('更新ダイアログ非表示', (WidgetTester tester) async {
      when(mockVersionCheck.needUpdate).thenReturn(false);
      when(mockVersionCheck.needPolicyAgreement).thenReturn(false);

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ていないことのチェック
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('ポリシーダイアログ表示', (WidgetTester tester) async {
      when(mockVersionCheck.needUpdate).thenReturn(false);
      when(mockVersionCheck.needPolicyAgreement).thenReturn(true);

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ているかのチェック
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('利用規約'), findsOneWidget);
      expect(find.byKey(Key('policy dialog')), findsOneWidget);
      expect(find.byType(InAppWebView), findsOneWidget);

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.data == '同意する' &&
              widget.style == TextStyle(color: Colors.red)),
          findsOneWidget);
    });

    testWidgets('ポリシーダイアログ非表示', (WidgetTester tester) async {
      when(mockVersionCheck.needUpdate).thenReturn(false);
      when(mockVersionCheck.needPolicyAgreement).thenReturn(false);

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ていないことのチェック
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('エラーダイアログ表示：初回', (WidgetTester tester) async {
      // RemoteConfigの取得に失敗した場合
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(false));
      when(mockVersionCheck.needUpdate).thenReturn(true);
      when(mockVersionCheck.needPolicyAgreement).thenReturn(true);

      when(mockTodayCalendar.getToday())
          .thenReturn(DateTime.parse('2020-02-22'));

      // 同意画面最終表示日時無し
      await binding.setSurfaceSize(testViewPortSize);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ているかのチェック
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('エラー'), findsOneWidget);
      expect(find.byKey(Key('error dialog')), findsOneWidget);
      expect(
          find.text('サーバーと接続できませんでした。通信環境をご確認の上、もう一度お試し下さい。'), findsOneWidget);

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.data == '再試行' &&
              widget.style == TextStyle(color: Colors.red)),
          findsOneWidget);

      // 他は出ていないことのチェック
      expect(find.byKey(Key('update dialog')), findsNothing);
      expect(find.byKey(Key('policy dialog')), findsNothing);
    });

    testWidgets('エラーダイアログ再表示回避期間外同日', (WidgetTester tester) async {
      // RemoteConfigの取得に成功した場合
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(false));
      when(mockTodayCalendar.getToday())
          .thenReturn(DateTime.parse('2020-02-22'));

      // 同意画面最終表示日時10日前
      await binding.setSurfaceSize(testViewPortSize);
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.VERSIONS_CHECK_LAST_DATE: '2020-02-12'});

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ているかのチェック
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('エラー'), findsOneWidget);
      expect(find.byKey(Key('error dialog')), findsOneWidget);
      expect(
          find.text('サーバーと接続できませんでした。通信環境をご確認の上、もう一度お試し下さい。'), findsOneWidget);

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.data == '再試行' &&
              widget.style == TextStyle(color: Colors.red)),
          findsOneWidget);
    });

    testWidgets('エラーダイアログ再表示回避期間外2', (WidgetTester tester) async {
      // RemoteConfigの取得に成功した場合
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(false));
      when(mockTodayCalendar.getToday())
          .thenReturn(DateTime.parse('2020-02-22'));

      // 同意画面最終表示日時10日前
      await binding.setSurfaceSize(testViewPortSize);
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.VERSIONS_CHECK_LAST_DATE: '2020-02-11'});

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ているかのチェック
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('エラー'), findsOneWidget);
      expect(find.byKey(Key('error dialog')), findsOneWidget);
      expect(
          find.text('サーバーと接続できませんでした。通信環境をご確認の上、もう一度お試し下さい。'), findsOneWidget);

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.data == '再試行' &&
              widget.style == TextStyle(color: Colors.red)),
          findsOneWidget);
    });

    testWidgets('エラーダイアログ再表示回避期間内', (WidgetTester tester) async {
      // RemoteConfigの取得に成功した場合
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(false));
      when(mockTodayCalendar.getToday())
          .thenReturn(DateTime.parse('2020-02-22'));

      // 同意画面最終表示日時10日前
      await binding.setSurfaceSize(testViewPortSize);
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.VERSIONS_CHECK_LAST_DATE: '2020-02-13'});

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testUpdater());

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ていないことのチェック
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('遷移のテスト', () {
    setUpAll(() async {
      testSetupLocator(
          analyticsService: MockAnalyticsService(),
          versionCheckService: mockVersionCheck);
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(true));
    });

    tearDownAll(() {
      cleanupLocator();
    });

    testWidgets('エラーダイアログ：再試行ボタン', (WidgetTester tester) async {
      when(mockTodayCalendar.getToday())
          .thenReturn(DateTime.parse('2020-02-02'));
      
      // RemoteConfigの取得に失敗した場合
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(false));
      when(mockVersionCheck.needUpdate).thenReturn(true);
      when(mockVersionCheck.needPolicyAgreement).thenReturn(true);

      // 同意画面最終表示日時無し
      await binding.setSurfaceSize(testViewPortSize);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // Alertダイアログが出ているかのチェック
      expect(find.byKey(Key('error dialog')), findsOneWidget);

      // 成功を返すように変更
      when(mockVersionCheck.versionCheck())
          .thenAnswer((_) => Future.value(true));
      when(mockVersionCheck.needUpdate).thenReturn(false);
      when(mockVersionCheck.needPolicyAgreement).thenReturn(false);
      // 再試行ボタン
      await tester.tap(find.text('再試行'));
      await tester.pumpAndSettle();
      expect(find.text('エラー'), findsNothing); // ダイアログが閉じたこと
    });

    testWidgets('同意画面->チュートリアル画面->更新ダイアログ', (WidgetTester tester) async {
      when(mockVersionCheck.needPolicyAgreement).thenReturn(true);
      when(mockVersionCheck.needUpdate).thenReturn(true);
      // チュートリアル未表示
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.TUTORIAL_DONE: false});

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // 同意画面
      expect(find.byKey(Key('policy dialog')), findsOneWidget);

      when(mockVersionCheck.needPolicyAgreement).thenReturn(false);
      await tester.tap(find.text('同意する'));
      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.byKey(Key('policy dialog')), findsNothing);
      // チュートリアル画面表示
      expect(find.byType(SlidingTutorial), findsOneWidget);
      // 最後までスワイプ
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), Offset(-500.0, 0.0), 300);
      await tester.pumpAndSettle();
      // タップ
      await tester.tap(find.byKey(Key('tutorialLastPage')));
      await tester.pumpAndSettle();
      expect(find.byType(SlidingTutorial), findsNothing);

      // 更新画面
      expect(find.byKey(Key('update dialog')), findsOneWidget);
    });

    testWidgets('同意画面->チュートリアル実施済み->更新ダイアログ', (WidgetTester tester) async {
      when(mockVersionCheck.needPolicyAgreement).thenReturn(true);
      when(mockVersionCheck.needUpdate).thenReturn(true);
      // チュートリアル実施済み
      SharedPreferences.setMockInitialValues(
          {PreferenceKey.TUTORIAL_DONE: true});

      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMyApp('2020-02-02'));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      // 同意画面
      expect(find.byKey(Key('policy dialog')), findsOneWidget);

      when(mockVersionCheck.needPolicyAgreement).thenReturn(false);
      await tester.tap(find.text('同意する'));
      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.byKey(Key('policy dialog')), findsNothing);
      // チュートリアル画面表示なし
      expect(find.byType(SlidingTutorial), findsNothing);

      // 更新画面
      expect(find.byKey(Key('update dialog')), findsOneWidget);
    });
  });
}
