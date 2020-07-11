import 'ProteinRecord.dart';

/// カレンダー表示用データ
class CalendarCellData {
  final DateTime calendar;
  ProteinRecord record;

  CalendarCellData(this.calendar, this.record);

  /// 合計ポイントを取得
  ///
  /// [CalendarCellData.record]がnullの場合は、0.0
  double getTotalPoint() {
    return (record?.totalPoints ?? 0.0);
  }

  /// [record.totalPoints]が11.0以上ならtrue
  bool isAchieved() {
    return getTotalPoint() >= 11.0;
  }

  /// [record.wentWorkout] ? true
  bool wentWorkout(){
    return record.wentWorkout;
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarCellData &&
        calendar == other.calendar &&
        record == other.record;
  }

  @override
  int get hashCode => calendar.hashCode ^ record.hashCode;

  @override
  String toString() {
    return "$calendar, $record";
  }
}
