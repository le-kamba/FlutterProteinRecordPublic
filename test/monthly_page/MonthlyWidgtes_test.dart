import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/data/CalendarData.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';
import 'package:proteinrecord/monthly_page/MonthlyViewModel.dart';
import 'package:proteinrecord/monthly_page/MonthlyWidgets.dart';
import 'package:proteinrecord/monthly_page/monthly_styles.dart';
import 'package:provider/provider.dart';

import '../data/dummy_data.dart';

/// MainPageで使うサブWidgetのテスト群
void main() {
  final testViewPortSize = Size(1080, 1776);
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  /// テスト用ウィジェットの起動
  MaterialApp testMainViewWidget(Widget widget) {
    // 今日を取得するクラスをモック化
    final mockCalendar = MockTodayCalendar();
    when(mockCalendar.getToday()).thenReturn(DateTime.parse('2020-02-01'));

    return MaterialApp(
      home: ChangeNotifierProvider<MonthlyViewModel>(
        create: (context) => MonthlyViewModel.withDisplayDate("2020-02-01",
            repository: MockRecordRepository(), todayCalendar: mockCalendar),
        child: Scaffold(
          body: widget,
        ),
      ),
    );
  }

  group('CalendarCell Widgetテスト', () {
    testWidgets('11.0点以上', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1_5, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      var celldata = CalendarCellData(DateTime(2020, 2, 20), record);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      expect(find.text('20'), findsOneWidget);
      expect(find.text('11.0'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('11.0点未満', (WidgetTester tester) async {
      var points = List.of([meat4, fish3, milk1, egg1, soy1, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      var celldata = CalendarCellData(DateTime(2020, 2, 20), record);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      expect(find.text('20'), findsOneWidget);
      expect(find.text('10.5'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsNothing);
    });

    testWidgets('record が null', (WidgetTester tester) async {
      var celldata = CalendarCellData(DateTime(2020, 2, 20), null);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      expect(find.text('20'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsNothing);
    });

    testWidgets('0.0> 合計点数文字の色', (WidgetTester tester) async {
      var points = List.of([meat0, fish0, milk0, egg0, soy0, etc0_5]);
      var record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      var celldata = CalendarCellData(DateTime(2020, 2, 20), record);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      WidgetPredicate predicate = (Widget widget) =>
          widget is Text &&
          widget.data == '0.5' &&
          widget.style == pointTextStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('0.0== 合計点数文字の色', (WidgetTester tester) async {
      var celldata = CalendarCellData(DateTime(2020, 2, 20), null);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      WidgetPredicate predicate = (Widget widget) =>
          widget is Text &&
          widget.data == '0.0' &&
          widget.style == zeroPointTextStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('前月カラー設定', (WidgetTester tester) async {
      // Create the widget by telling the tester to build it.
      var celldata = CalendarCellData(DateTime(2020, 1, 26), null);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      // セル背景色
      WidgetPredicate predicate = (Widget widget) =>
          widget is Container && widget.decoration == otherMonthBackground;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // 日付ラベルの文字色
      predicate = (Widget widget) =>
          widget is Text &&
          widget.data == "26" &&
          widget.style == otherMonthTextStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('翌月カラー設定', (WidgetTester tester) async {
      // Create the widget by telling the tester to build it.
      var celldata = CalendarCellData(DateTime(2020, 3, 1), null);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      // セル背景色
      WidgetPredicate predicate = (Widget widget) =>
          widget is Container && widget.decoration == otherMonthBackground;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // 日付ラベルの文字色
      predicate = (Widget widget) =>
          widget is Text &&
          widget.data == "1" &&
          widget.style == otherMonthTextStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('当月カラー設定', (WidgetTester tester) async {
      // 起動日が2/1なのでそれ以外の日でチェック
      var celldata = CalendarCellData(DateTime(2020, 2, 4), null);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      // セル背景色
      WidgetPredicate predicate = (Widget widget) =>
          widget is Container && widget.decoration == todayMonthBackground;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // 日付ラベルの文字色
      predicate = (Widget widget) =>
          widget is Text &&
          widget.data == "4" &&
          widget.style == todayMonthTextStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });

    testWidgets('当日カラー設定', (WidgetTester tester) async {
      var celldata = CalendarCellData(DateTime(2020, 2, 1), null);
      await tester.pumpWidget(testMainViewWidget(CalendarCell(celldata)));

      // セル背景色
      WidgetPredicate predicate = (Widget widget) =>
          widget is Container && widget.decoration == todayBackground;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      // 日付ラベルの文字色
      predicate = (Widget widget) =>
          widget is Text &&
          widget.data == "1" &&
          widget.style == todayMonthTextStyle;
      expect(find.byWidgetPredicate(predicate), findsOneWidget);
    });
  });

  group('WeekdayLabel Widgetテスト', () {
    testWidgets('ラベルと文字スタイル', (WidgetTester tester) async {
      await tester.pumpWidget(
          testMainViewWidget(WeekdayLabel(label: "日", color: Colors.red)));
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.data == '日' &&
              widget.style == TextStyle(color: Colors.red, fontSize: 18)),
          findsOneWidget);
    });
  });

  group('CalendarWidget テスト', () {
    // 曜日ラベル--------------------------------------------
    final labels = {
      '日': Colors.red,
      '月': Colors.grey,
      '火': Colors.grey,
      '水': Colors.grey,
      '木': Colors.grey,
      '金': Colors.grey,
      '土': Colors.blue,
    };
    testWidgets('曜日ラベル', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMainViewWidget(CalendarWidget()));

      labels.forEach((key, value) {
        expect(
            find.byWidgetPredicate((Widget widget) =>
                widget is Text &&
                widget.data == key &&
                widget.style == TextStyle(color: value, fontSize: 18)),
            findsOneWidget);
      });
    });
  });

  group('CalendarView テスト', () {
    // セル--------------------------------------------
    testWidgets('カレンダーグリッド:アイテム数とカラム数', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMainViewWidget(CalendarWidget()));

      WidgetPredicate predicate = (Widget widget) =>
//  @formatter:off
          widget is GridView &&
          widget.semanticChildCount == 42 &&
          widget.gridDelegate is SliverGridDelegateWithFixedCrossAxisCount &&
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
                  .crossAxisCount == 7;
//  @formatter:on
      expect(find.byWidgetPredicate(predicate), findsOneWidget);

      predicate = (Widget widget) =>
      widget is CalendarCell;
      expect(find.byWidgetPredicate(predicate), findsNWidgets(42));
    });

    // セル(日付)--------------------------------------------

    final dates = {
      '26': 2,
      "27": 2, "28": 2, "29": 2, "30": 1, "31": 1,
      "1": 2, "2": 2, "3": 2, "4": 2, "5": 2, "6": 2, "7": 2,
      "8": 1, "9": 1, "10": 1, "11": 1, "12": 1, "13": 1, "14": 1,
      "15": 1, "16": 1, "17": 1, "18": 1, "19": 1, "20": 1, "21": 1,
      "22": 1, "23": 1, "24": 1, "25": 1,
    };

    testWidgets('カレンダーグリッド:日付', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);

      await tester.pumpWidget(testMainViewWidget(CalendarWidget()));
      await tester.pumpAndSettle();

      dates.forEach((key, value) {
        expect(find.text(key), findsNWidgets(value));
      });
    });
  });
}
