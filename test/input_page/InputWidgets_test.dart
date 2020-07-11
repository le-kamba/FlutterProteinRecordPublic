import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';
import 'package:proteinrecord/data/RecordClassification.dart';
import 'package:proteinrecord/input_page/InputViewModel.dart';
import 'package:proteinrecord/input_page/InputWidgets.dart';
import 'package:proteinrecord/input_page/input_styles.dart';
import 'package:provider/provider.dart';

import '../TestApp.dart';
import '../data/dummy_data.dart';

/// InputPageで使うサブWidgetのテスト群
void main() {
  /// テスト用ウィジェットの起動
  MaterialApp testInputViewWidget(Widget widget, ProteinRecord record) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<InputPageBloc>(
              create: (context) => InputPageBloc(),
              dispose: (context, bloc) => bloc.dispose()),
          ChangeNotifierProvider<InputViewModel>(
              create: (context) =>
                  InputViewModel(record, repository: MockRecordRepository())),
        ],
        child: Scaffold(
          body: widget,
        ),
      ),
    );
  }

  group('TypeRow Widgetテスト', () {
    testWidgets('カウントあり', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester.pumpWidget(testInputViewWidget(
          TypeRow(MajorType.FISH, fishPoints.minors[1], 1), record));

      // 小分類ラベル
      WidgetPredicate predicate = (Widget widget) =>
          widget is Text &&
          widget.data == '手のひら半分 \n(30〜40g)' &&
          widget.style == minorLabelStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // 画像
      expect(findByAssetImage('assets/fish_half.png'), findsOneWidget);

      // 基礎点
      predicate = (Widget widget) =>
          widget is Text &&
          widget.data == '1.0' &&
          widget.style == basePointLabelStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // カウント
      predicate = (Widget widget) =>
          widget is Text &&
          widget.data == '1' &&
          widget.style == countLabelStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // アイコン
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('カウントなし', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester.pumpWidget(testInputViewWidget(
          TypeRow(MajorType.MILK, milkPoints.minors[1], 1), record));

      expect(find.text('ヨーグルト \n(1個)'), findsOneWidget);
      expect(find.text('0.5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('notesあり', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester.pumpWidget(testInputViewWidget(
          TypeRow(MajorType.SOY, soyPoints.minors[2], 2), record));

      expect(find.text('豆類 ※ナッツ類を除く\n(30g)'), findsOneWidget);
      expect(find.text('0.5'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('TypeBoard Widgetのテスト', () {
    testWidgets('List 複数行', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester
          .pumpWidget(testInputViewWidget(TypeBoard(fishPoints), record));

      // ListViewのチェック
      WidgetPredicate predicate = (Widget widget) =>
          widget is ListView &&
          widget.shrinkWrap == true &&
          widget.physics is NeverScrollableScrollPhysics &&
          widget.semanticChildCount == 4;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // TypeRowウィジェットの数
      predicate = (Widget widget) => widget is TypeRow;
      expect(find.byWidgetPredicate(predicate), findsNWidgets(4));
    });

    testWidgets('List 単一行', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester
          .pumpWidget(testInputViewWidget(TypeBoard(eggPoints), record));

      // ListViewのチェック
      WidgetPredicate predicate = (Widget widget) =>
          widget is ListView && widget.semanticChildCount == 1;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // TypeRowウィジェットの数
      predicate = (Widget widget) => widget is TypeRow;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('Box Decoration-Border Top', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester
          .pumpWidget(testInputViewWidget(TypeBoard(meatPoints), record));

      final BuildContext context = tester.element(
          find.byWidgetPredicate((Widget widget) => widget is ListView));

      // ListViewのチェック
      WidgetPredicate predicate = (Widget widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).border ==
              Border(
                // index==0はleftのみ
                left: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).dividerColor,
                ),
              );

      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('Box Decoration-Border Top以外', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester
          .pumpWidget(testInputViewWidget(TypeBoard(meatPoints), record));

      final BuildContext context = tester.element(
          find.byWidgetPredicate((Widget widget) => widget is ListView));

      // ListViewのチェック
      WidgetPredicate predicate = (Widget widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).border ==
              Border(
                left: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).dividerColor,
                ),
                top: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).dividerColor,
                ),
              );

      expect(find.byWidgetPredicate(predicate), findsNWidgets(3));
    });
  });

  group('TypeCardWidgetのテスト', () {
    testWidgets('大分類テキスト', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester
          .pumpWidget(testInputViewWidget(TypeCardWidget(fishPoints), record));

      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == '魚' &&
              widget.style == majorLabelStyle),
          findsOneWidget);
    });

    testWidgets('大分類背景色', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await tester
          .pumpWidget(testInputViewWidget(TypeCardWidget(fishPoints), record));

      expect(
          find.byWidgetPredicate((widget) =>
              widget is Container &&
              widget.decoration ==
                  BoxDecoration(color: Color.fromARGB(255, 197, 225, 165))),
          findsOneWidget);
    });

    testWidgets('nullレコード', (WidgetTester tester) async {
      var record = ProteinRecord("2020-02-20", null);
      await tester
          .pumpWidget(testInputViewWidget(TypeCardWidget(fishPoints), record));

      expect(find.text('0'), findsNWidgets(4));
    });
  });
}
