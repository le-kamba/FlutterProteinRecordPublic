import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';
import 'package:proteinrecord/data/RecordClassification.dart';
import 'package:proteinrecord/input_page/InputPage.dart';
import 'package:proteinrecord/input_page/InputWidgets.dart';

import '../TestApp.dart';
import '../data/dummy_data.dart';

void main() {
  final testViewPortSize = Size(1080, 1776);

  /// テスト用の起動
  Widget testInputPage(ProteinRecord record) {
    // RepositoryクラスはTestApp内でMockを使用しています
    return TestApp(InputPage(record: record));
  }

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  group('InputPageのウィジェット表示テスト', () {
    testWidgets('タイトルのチェック', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      expect(find.text('2020/02/20'), findsOneWidget);
    });

    testWidgets('削除アイコン', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('ヘッダー', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      expect(find.text('基本点数'), findsOneWidget);
      expect(find.text('摂取個数'), findsOneWidget);
    });

    testWidgets('フッター/カウントあり', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      expect(find.text('合計点数：'), findsOneWidget);
      expect(find.text('11.0'), findsOneWidget);
    });

    testWidgets('フッター/カウント無し', (WidgetTester tester) async {
      var record = ProteinRecord("2020-02-20", null);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      expect(find.text('合計点数：'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('点数表/カウントあり', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      WidgetPredicate predicate = (Widget widget) =>
          widget is ListView && widget.semanticChildCount == 6;

      expect(find.byWidgetPredicate(predicate), findsOneWidget);
      expect(find.byType(TypeCardWidget), findsNWidgets(6));
    });

    testWidgets('点数表/カウントなし', (WidgetTester tester) async {
      var record = ProteinRecord("2020-02-20", null);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      WidgetPredicate predicate = (Widget widget) =>
          widget is ListView && widget.semanticChildCount == 6;

      expect(find.byWidgetPredicate(predicate), findsOneWidget);
      expect(find.byType(TypeCardWidget), findsNWidgets(6));
    });
  });

  group('InputPageのタップ系動作テスト', () {
    final mockAnalytics = MockAnalyticsService();

    setUpAll(() async {
      testSetupLocator(
          analyticsService: mockAnalytics,
          versionCheckService: FalseMockVersionCheckService());
    });

    /// カードタイプ別にすべてタップ
    MajorType.values.forEach((majorType) {
      testWidgets('カードタップ($majorType)/カウントあり', (WidgetTester tester) async {
        var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
        var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

        await binding.setSurfaceSize(testViewPortSize);
        await tester.pumpWidget(testInputPage(record));

        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key(majorType.toString())));
        // TODO 詳細画面への遷移を確認
      });
    });

    /// カードタイプ別にすべてタップ
    MajorType.values.forEach((majorType) {
      testWidgets('カードタップ($majorType)/カウントなし', (WidgetTester tester) async {
        var record = ProteinRecord("2020-02-20", null);

        await binding.setSurfaceSize(testViewPortSize);
        await tester.pumpWidget(testInputPage(record));

        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key(majorType.toString())));
        // TODO 詳細画面への遷移を確認
      });
    });

    testWidgets('削除アイコンタップ', (WidgetTester tester) async {
      var points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();
      expect(find.text('11.0'), findsOneWidget);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('OK'), findsNothing);

      await tester.tap(find.byIcon(Icons.delete));

      // 確認ダイアログ表示
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      verify(mockAnalytics.sendButtonEvent(buttonName: '削除アイコン'));
    });

    testWidgets('削除アイコン-cancelタップ', (WidgetTester tester) async {
      var points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();
      expect(find.text('11.0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));

      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));

      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('11.0'), findsOneWidget);

      verify(mockAnalytics.sendButtonEvent(buttonName: '削除-キャンセル'));
    });

    testWidgets('削除アイコン-OKタップ', (WidgetTester tester) async {
      var points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();
      expect(find.text('11.0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));

      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('OK'));

      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('11.0'), findsNothing);
      expect(find.text('0.0'), findsOneWidget);

      verify(mockAnalytics.sendClearEvent());
    });

    testWidgets('カウントアップ/合計点数反映', (WidgetTester tester) async {
      var points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();
      expect(find.text('11.0'), findsOneWidget);

      await tester.tap(find.byKey(Key('up:${MajorType.MILK.toString()}.1')));
      await tester.pumpAndSettle();

      expect(find.text('11.5'), findsOneWidget);
    });

    testWidgets('カウントアップ/カウント数反映', (WidgetTester tester) async {
      var points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      WidgetPredicate predicate = (Widget widget) =>
          widget is Text &&
          widget.key == Key('count:${MajorType.SOY.toString()}.1') &&
          widget.data == '1';
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      await tester.tap(find.byKey(Key('up:${MajorType.SOY.toString()}.1')));
      await tester.pumpAndSettle();

      predicate = (Widget widget) =>
          widget is Text &&
          widget.key == Key('count:${MajorType.SOY.toString()}.1') &&
          widget.data == '2';
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('カウントダウン/合計点数反映', (WidgetTester tester) async {
      var points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();
      expect(find.text('11.0'), findsOneWidget);

      await tester.tap(find.byKey(Key('down:${MajorType.MEAT.toString()}.2')));
      await tester.pumpAndSettle();

      expect(find.text('10.0'), findsOneWidget);
    });

    testWidgets('カウントダウン/カウント数反映', (WidgetTester tester) async {
      var points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);

      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInputPage(record));

      await tester.pumpAndSettle();

      WidgetPredicate predicate = (Widget widget) =>
          widget is Text &&
          widget.key == Key('count:${MajorType.FISH.toString()}.1') &&
          widget.data == '1';
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      await tester.tap(find.byKey(Key('down:${MajorType.FISH.toString()}.1')));
      await tester.pumpAndSettle();

      predicate = (Widget widget) =>
          widget is Text &&
          widget.key == Key('count:${MajorType.FISH.toString()}.1') &&
          widget.data == '0';
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });
  });
}
