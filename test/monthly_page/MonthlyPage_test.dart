import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proteinrecord/monthly_page/MonthlyPage.dart';
import 'package:proteinrecord/monthly_page/MonthlyWidgets.dart';
import 'package:proteinrecord/top_page/TopViewModel.dart';
import 'package:provider/provider.dart';

import '../TestApp.dart';

/// MainPageのテスト
void main() {
  final testViewPortSize = Size(1080, 1776);

  /// テスト用の起動
  Widget testMonthlyPage(int index) {
    // 本来はPageViewの中でAppBarが出ているはずなのでテスト用に出す
    return TestApp(Scaffold(
        appBar: AppBar(
          title: Text('TEST'),
        ),
        // 本来はTopViewが持っているProviderをテスト用に設定
        body: Provider<TopPageBloc>(
            create: (context) => TopPageBloc(),
            dispose: (context, bloc) => bloc.dispose(),
            child: MonthlyPage(
              date: "2020-02-01",
              index: index,
            ))));
  }

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  group('MonthlyPageのテスト', () {
    testWidgets('ヘッダー日付のチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testMonthlyPage(0));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(find.text('2020年2月'), findsOneWidget);
    });

    testWidgets('ローディングのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.runAsync(() async {
        await tester.pumpWidget(testMonthlyPage(0));
        expect(
            find.byWidgetPredicate(
                (Widget widget) => widget is CircularProgressIndicator),
            findsOneWidget);

        // 処理の終了後、表示更新が終わるのを待つ
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate(
                (Widget widget) => widget is CircularProgressIndicator),
            findsNothing);
      });
    });

    testWidgets('CalendarWidgetのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testMonthlyPage(0));

      await tester.pumpAndSettle(); // ローディング終了を待つ

      expect(
          find.byWidgetPredicate((Widget widget) => widget is CalendarWidget),
          findsOneWidget);
    });

    testWidgets('フッターのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testMonthlyPage(0));

      await tester.pumpAndSettle(); // ローディング終了を待つ
      expect(find.text(MonthlyPage.footerLabel1), findsOneWidget);
    });
  });

  testWidgets('index:0/右矢印アイコン表示', (WidgetTester tester) async {
    await binding.setSurfaceSize(testViewPortSize);

    await tester.pumpWidget(testMonthlyPage(-1));

    await tester.pumpAndSettle(); // ローディング終了を待つ

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('index:1/左矢印アイコン表示', (WidgetTester tester) async {
    await binding.setSurfaceSize(testViewPortSize);

    await tester.pumpWidget(testMonthlyPage(0));

    await tester.pumpAndSettle(); // ローディング終了を待つ

    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  });
}
