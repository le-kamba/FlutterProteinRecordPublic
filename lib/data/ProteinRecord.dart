import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../data/RecordClassification.dart';
import 'database.dart';

/// レコード
class ProteinRecord {
  /// 日付(yyyy-MM-dd)
  //non-null
  String date;

  /// 区分別点数
  //nullable
  Map<MajorType, List<int>> points;

  /// 合計点数
  double totalPoints = 0;

  /// ワークアウトしたフラグ
  bool wentWorkout = false;

  /// デフォルトコンストラクタ
  /// [date] データの日付yyyy-MM-dd
  /// [points] 区分別点数のMap(nullable)
  ProteinRecord(this.date, [this.points, this.wentWorkout]) {
    try {
      DateTime.parse(date);
      _calcTotal();
    } on FormatException catch (e) {
      debugPrint("日付フォーマットが間違っています。yyyy-MM-ddで指定して下さい。");
      throw e;
    }
  }

  /// 小分類の点数を計算
  /// 小分類クラスから基本点数を持ってきて、カウント分掛けている
  double _calcMinors(
      List<MinorClassification> minorClassList, List<int> counts) {
    double points = 0.0;
    counts?.asMap()?.forEach((index, count) {
      points += count * minorClassList[index].basePoint;
    });
    return points;
  }

  /// すべての合計点数を算出
  void _calcTotal() {
    totalPoints = 0.0;
    points?.forEach((key, minorCounts) {
      totalPoints +=
          _calcMinors(proteinClassifications[key].minors, minorCounts);
    });
  }

  void _checkMapInitialized(MajorType key) {
    if (points == null) {
      points = Map();
    }
    if (points[key] == null) {
      points[key] = List.filled(proteinClassifications[key].minors.length, 0);
    }
  }

  /// 小分類項目の摂取カウントをアップ
  /// [key] MajorType
  /// [index] MinorType Index
  /// return カウントアップしたらtrue,しなかったらしなかったらfalse
  bool addCount(MajorType key, int index) {
    _checkMapInitialized(key);
    if (points[key][index] == 9) return false;
    points[key][index] += 1;
    _calcTotal();
    return true;
  }

  /// 小分類項目の摂取カウントをダウン
  /// [key] MajorType
  /// [index] MinorType Index
  /// return カウントダウンしたらtrue,しなかったらしなかったらfalse
  bool subCount(MajorType key, int index) {
    _checkMapInitialized(key);
    if (points[key][index] == 0) return false;
    points[key][index] -= 1;
    _calcTotal();
    return true;
  }

  /// 日付のみでデータを空で作成するコンストラクタ
  /// [dateTime] データの日付 DateTime型
  /// このコンストラクタ以外は、日付には文字列を取ることに注意
  ProteinRecord.empty(DateTime dateTime) {
    this.date = formatDateTimeToRecord(dateTime);
  }

  /// 各ポイントを個別に引数で渡せるコンストラクタ
  /// [date] データの日付yyyy-MM-dd
  /// [meatPoints] 肉類小分類カウントリスト
  /// [fishPoints] 魚類小分類カウントリスト
  /// [milkPoints] 乳製品小分類カウントリスト
  /// [eggPoints] 卵小分類カウントリスト
  /// [soyPoints] 豆類小分類カウントリスト
  /// [etcPoints] その他小分類カウントリスト
  ProteinRecord.fromPoints(this.date,
      {List<int> meatPoints,
      List<int> fishPoints,
      List<int> milkPoints,
      List<int> eggPoints,
      List<int> soyPoints,
      List<int> etcPoints,
      bool workout = false}) {
    points = Map();
    points[MajorType.MEAT] = meatPoints;
    points[MajorType.FISH] = fishPoints;
    points[MajorType.MILK] = milkPoints;
    points[MajorType.EGG] = eggPoints;
    points[MajorType.SOY] = soyPoints;
    points[MajorType.ETC] = etcPoints;
    _calcTotal();
    wentWorkout = workout;
  }

  /// ポイントのリストで初期化できるコンストラクタ
  /// [date] データの日付yyyy-MM-dd
  /// [pointsList] 各大分類のカウントデータのリスト
  /// [pointsList]の順番は[MajorType]のindex順になっている必要があります
  ProteinRecord.fromList(this.date,
      {List<List<int>> pointsList, bool workout = false}) {
    if (pointsList.length < 6) {
      throw new ArgumentError("リストの長さが不正です。");
    }
    points = new HashMap();
    points[MajorType.MEAT] = pointsList[MajorType.MEAT.index];
    points[MajorType.FISH] = pointsList[MajorType.FISH.index];
    points[MajorType.MILK] = pointsList[MajorType.MILK.index];
    points[MajorType.EGG] = pointsList[MajorType.EGG.index];
    points[MajorType.SOY] = pointsList[MajorType.SOY.index];
    points[MajorType.ETC] = pointsList[MajorType.ETC.index];
    _calcTotal();
    this.wentWorkout = workout;
  }

  /// すべてのポイントをzeroクリアする
  void clearAllPoints() {
    points?.forEach((majorType, counts) {
      counts?.fillRange(0, counts.length, 0);
    });
    _calcTotal();
    wentWorkout = false;
  }

  @override
  bool operator ==(Object other) {
    return other is ProteinRecord &&
        date == other.date &&
        DeepCollectionEquality().equals(points, other.points) &&
        totalPoints == other.totalPoints &&
        wentWorkout == other.wentWorkout;
  }

  @override
  int get hashCode =>
      date.hashCode ^
      points.hashCode ^
      totalPoints.hashCode ^
      wentWorkout.hashCode;

  @override
  String toString() {
    return "$date, ${totalPoints.toStringAsFixed(1)}, ${wentWorkout.toString()}";
  }

  /// レコード用の'yyyy-MM-dd`形式に[dateTime]をフォーマットする
  static String formatDateTimeToRecord(DateTime dateTime) {
    initializeDateFormatting('ja');
    var format = new DateFormat('yyyy-MM-dd', "ja_JP");
    return format.format(dateTime);
  }

  /// Hive保存用のBoxモデルに変換する
  RecordModel toBoxModel() {
    return RecordModel(
        date,
        points == null ? null : points[MajorType.MEAT],
        points == null ? null : points[MajorType.FISH],
        points == null ? null : points[MajorType.MILK],
        points == null ? null : points[MajorType.EGG],
        points == null ? null : points[MajorType.SOY],
        points == null ? null : points[MajorType.ETC],
        wentWorkout);
  }

  /// HiveのBoxモデルから変換する
  static ProteinRecord fromBoxModel(RecordModel model) {
    return ProteinRecord.fromPoints(model.date,
        meatPoints: model.meat,
        fishPoints: model.fish,
        milkPoints: model.milk,
        eggPoints: model.egg,
        soyPoints: model.soy,
        etcPoints: model.etc,
        workout: model.wentWorkout);
  }
}
