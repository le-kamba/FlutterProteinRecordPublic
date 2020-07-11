import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

import '../constants.dart';
import '../data/CalendarData.dart';
import '../data/ProteinRecord.dart';
import '../data/TodayCalendar.dart';
import '../main.dart';
import '../repository/ProteinRecordRepository.dart';
import '../services/AnalyticsService.dart';
import '../services/NavigationService.dart';

/// MainPage用のViewModelクラス
class MonthlyViewModel with ChangeNotifier {
  /// カレンダーセル表示データリスト
  List<CalendarCellData> _cellData;

  List<CalendarCellData> get cellData => _cellData;

  /// ローディング表示フラグ
  bool _showLoading = false;

  bool get showLoading => _showLoading;

  /// 表示年月(yyyy-MM-dd)
  String displayDate;

  /// カレンダーページの最初の日(表示年月と同じ年月とは限らない)
  DateTime firstDayInPage;

  /// カレンダーページの最後の日
  DateTime rangeEndDay;

  /// ページ内のレコード
  List<ProteinRecord> _recordList;

  List<ProteinRecord> get recordList => _recordList;

  /// データリポジトリ
  final ProteinRecordRepository repository;

  /// [今日]を取るためのユーティリティクラス
  TodayCalendar todayCalendar;

  /// [今日]の日付更新監視用に持っておく
  DateTime today;

  /// コンストラクタ
  MonthlyViewModel({@required this.repository, this.todayCalendar}) {
    _init();
  } // テスト用にデータロードが走らないのも用意

  /// 表示年月日 [date] で初期化するコンストラクタ
  ///
  /// [date] は"yyyy-MM-dd"の形式であること。
  MonthlyViewModel.withDisplayDate(String date,
      {@required this.repository, this.todayCalendar}) {
    setDisplayDate(date);
    fetchData();
    _init();
  }

  void _init() {
    if (todayCalendar == null) {
      todayCalendar = TodayCalendar();
    }
    today = todayCalendar.getToday();
  }

  /// 表示年月日をセットする
  @visibleForTesting
  void setDisplayDate(String displayDate) {
    this.displayDate = displayDate;
    final Tuple2<DateTime, DateTime> ymd = getFromToYMD(displayDate);
    firstDayInPage = ymd.item1;
    rangeEndDay = ymd.item2;
  }

  /// データ取得を開始
  void fetchData() {
    _showLoading = true;
    createCalendarData();
  }

  /// クエリー用のfromとto日付を取得する
  ///
  /// [yyyyMMdd] `yyyy-MM-dd`の形の日付を受け取り、
  /// "<DateTime, DateTime>"のTuple2を返します。
  @visibleForTesting
  Tuple2<DateTime, DateTime> getFromToYMD(String yyyyMMdd) {
    final o = DateTime.parse(yyyyMMdd);
    var from = DateTime(o.year, o.month, 1);
    // 日曜日になるまで日付を遡る
    var dw = from.weekday;
    while (dw != DateTime.sunday) {
      from = from.subtract(Duration(days: 1));
      dw = from.weekday;
    }
    // 42日後にする
    final to = from.add(Duration(days: 42));
    return Tuple2(from, to);
  }

  /// カレンダーデータを非同期で作成する
  @visibleForTesting
  Future<void> createCalendarData() async {
    initializeDateFormatting('ja');
    final format = new DateFormat('yyyy-MM-dd', "ja_JP");

    _recordList = await repository.searchRange(
        startDate: format.format(firstDayInPage),
        endDate: format.format(rangeEndDay));
    _cellData = createCellData(firstDayInPage, _recordList);

    // リスナーに通知(表示を更新)
    notifyListeners();

    _showLoading = false;
  }

  /// カレンダーのセル表示データリストを作成
  @visibleForTesting
  List<CalendarCellData> createCellData(
      DateTime from, List<ProteinRecord> logs) {
    var cal = DateTime(from.year, from.month, from.day);
    List<CalendarCellData> list = [];
    int index = 0;
    for (int i = 1; i <= 42; i++) {
      ProteinRecord log;
      if (logs != null &&
          index < logs.length &&
          DateTime.parse(logs[index].date) == cal) {
        log = logs[index++];
      }
      list.add(CalendarCellData(DateTime(cal.year, cal.month, cal.day), log));
      cal = cal.add(Duration(days: 1));
    }
    return list;
  }

  /// [date] が表示月と同じかチェック
  ///
  /// [date.year]が違っていても[date.month]が同じであればtrueが返ります
  ///
  /// ※１ページ内に年の異なる月が存在することははありえないため
  bool isTodayMonth(DateTime date) {
    final display = DateTime.parse(displayDate);
    return display.month == date.month;
  }

  /// [date] が今日(アプリ起動日)と同じ年月日かチェック
  bool isToday(DateTime date) {
    if (today == null) today = todayCalendar.getToday();
    return (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  /// 次の画面に遷移させる
  /// [data]セル表示データ[CalendarCellData]
  void navigateNextPage(CalendarCellData data) async {
    // Analytics送信
    final analyticsService = locator<AnalyticsService>();
    analyticsService.sendCalendarEvent();

    // recordがnullの場合は、新規作成
    ProteinRecord record =
        data?.record ?? new ProteinRecord.empty(data.calendar);
    // ルート遷移
    final NavigationService _navigationService = locator<NavigationService>();
    final result =
        await _navigationService.navigateTo(RoutePathName.INPUT, args: record);
    debugPrint(result.toString());
    if (result) {
      data.record = record;
      // trueなら更新があったのでウィジェットを再ビルドしなければならない
      notifyListeners();
    }
  }

  /// 今日の日付を取り直す
  /// アプリ起動中に日付が変わった場合の対処
  /// 特にiOS向け
  void updateToday() {
    final oldDate = today;
    today = todayCalendar.getToday();

    if (oldDate.day != today.day) {
      notifyListeners();
    }
  }
}
