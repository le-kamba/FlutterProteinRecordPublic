/// 起動日の日付を'yyyy-MM-dd`の文字列で返すクラス
/// テストでDI出来るようにするため、クラス化
class TodayCalendar {
  DateTime getToday() {
    return DateTime.now();
  }
}
