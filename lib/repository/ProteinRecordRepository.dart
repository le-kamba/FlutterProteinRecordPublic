import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';

import '../data/database.dart';

/// プロテイン記録リポジトリクラス
class ProteinRecordRepository {
  RecordModelBox _recordBox;

  /// コンストラクタ
  /// [recordModelBox] Boxへのアクセサクラス
  ProteinRecordRepository(RecordModelBox recordModelBox) {
    _recordBox = recordModelBox;
  }

  /// 全件データを取得
  Future<List<ProteinRecord>> fetchAll() async {
    final box = await _recordBox.box;
    List<RecordModel> list = box.values.toList();
    var recordList = List<ProteinRecord>();
    list?.forEach((model) => recordList.add(ProteinRecord.fromBoxModel(model)));
    return recordList;
  }

  /// 月間データを取得
  /// [startDate] 検索開始日付を表す文字列(yyyy-MM-dd)
  /// [endDate] 検索終了日付を表す文字列(yyyy-MM-dd)(この日付を含まない)
  Future<List<ProteinRecord>> searchRange(
      {@required String startDate, @required String endDate}) async {
    // formatチェック
    try {
      DateTime.parse(startDate);
      DateTime.parse(endDate);
    } on FormatException catch (e) {
      debugPrint(
          "日付フォーマットが間違っています。yyyy-MM-ddで指定して下さい。[$startDate or $endDate]");
      throw e;
    }

    var recordList = List<ProteinRecord>();

    try {
      final box = await _recordBox.box;
      List<RecordModel> list = box.values
          .where((n) =>
              n.date.compareTo(startDate) >= 0 && n.date.compareTo(endDate) < 0)
          .toList();
      list?.forEach(
          (model) => recordList.add(ProteinRecord.fromBoxModel(model)));
    } catch (e) {
      debugPrint("データの取得で例外発生しました。 $e.toString()");
    }
    return recordList;
  }

  /// レコードの変更を保存
  Future<void> save(ProteinRecord record) async {
    final box = await _recordBox.box;
    await box.put(record.date, record.toBoxModel());
  }

  /// レコードを全件追加
  Future<void> addAll(List<ProteinRecord> records) async {
    final box = await _recordBox.box;
    records.forEach((record) => box.put(record.date, record.toBoxModel()));
  }

  /// 日付を指定してレコードを取得
  /// return : nullable
  Future<ProteinRecord> get(String date) async {
    final box = await _recordBox.box;
    final model = await box.get(date);
    if (model == null) return null;
    return ProteinRecord.fromBoxModel(model);
  }

  /// 全件削除
  Future<void> deleteAll() async {
    final Box box = await _recordBox.box;
    await box.deleteFromDisk();
    await _recordBox.open(); // もう一度開く
  }

  /// 1件削除
  Future<void> delete(String date) async {
    final Box box = await _recordBox.box;
    await box.delete(date);
  }

  /// クローズ
  dispose() async {
    final Box box = await _recordBox.box;
    await box.close(); // 必要ないと言われているが・・・
  }
}
