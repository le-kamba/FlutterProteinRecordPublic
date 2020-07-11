import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';
import 'package:proteinrecord/data/RecordClassification.dart';
import 'package:proteinrecord/data/database.dart';

import 'dummy_data.dart';

/// ProteinRecordクラスのテスト
void main() {
  group("ProteinRecordクラス static関数テスト", () {
    test('formatDateTimeToRecord:日付変換', () {
      DateTime time = DateTime.parse("2020-02-22");
      final date = ProteinRecord.formatDateTimeToRecord(time);
      expect(date, "2020-02-22");
    });
  });

  group("ProteinRecordクラスのテスト", () {
    test('日付フォーマットOK', () {
      final record = ProteinRecord("2020-03-20", null);
      expect(record, isNotNull);
    });

    test('日付フォーマットエラー', () {
      expect(() => ProteinRecord("2020/03/20", null), throwsFormatException);
    });

    test('コンストラクタ fromListのサイズエラー', () {
      final points = List.of([meat4, fish3, milk1, egg1, etc2_5]);
      expect(() => ProteinRecord.fromList("2020-03-20", pointsList: points),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test('コンストラクタ empty', () {
      DateTime time = DateTime.parse("2020-02-22");
      final record = ProteinRecord.empty(time);

      expect(record, isNotNull);
      expect(record.date, equals("2020-02-22"));
      expect(record.points, isNull);
    });

    test('合計点計算 with Map', () {
      final points = {
        MajorType.MEAT: meat4,
        MajorType.FISH: fish3,
        MajorType.EGG: egg1,
        MajorType.MILK: milk1,
        MajorType.ETC: etc2_5,
      };
      final record = ProteinRecord("2020-03-20", points);
      expect(record.totalPoints, 11.5);
    });

    test('合計点計算 fromPoints', () {
      final record = ProteinRecord.fromPoints("2020-03-20",
          meatPoints: meat4,
          fishPoints: fish3,
          eggPoints: egg1,
          milkPoints: milk1,
          etcPoints: etc2_5);
      expect(record.totalPoints, 11.5);
    });

    test('合計点計算 fromList', () {
      final points = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final record = ProteinRecord.fromList("2020-03-20", pointsList: points);
      expect(record.totalPoints, 11.5);
    });

    test('operator ==', () {
      final points1 = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final points2 = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final record1 = ProteinRecord.fromList("2020-03-20", pointsList: points1);
      final record2 = ProteinRecord.fromList("2020-03-20", pointsList: points2);
      expect(record1 == record2, isTrue);
    });

    test('operator ==/faile with workout', () {
      final points1 = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final points2 = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final record1 = ProteinRecord.fromList("2020-03-20",
          pointsList: points1, workout: true);
      final record2 = ProteinRecord.fromList("2020-03-20",
          pointsList: points2, workout: false);
      expect(record1 == record2, isFalse);
    });

    test('operator ==/pass with workout', () {
      final points1 = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final points2 = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final record1 = ProteinRecord.fromList("2020-03-20",
          pointsList: points1, workout: true);
      final record2 = ProteinRecord.fromList("2020-03-20",
          pointsList: points2, workout: true);
      expect(record1 == record2, isTrue);
    });

    test('clearAllPoints', () {
      final points = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final record = ProteinRecord.fromList("2020-03-20", pointsList: points);
      expect(record.totalPoints, 11.5);
      record.clearAllPoints();
      expect(record.totalPoints, 0.0);
    });

    test('toBoxModel', () {
      final points = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final record = ProteinRecord.fromList("2020-03-20", pointsList: points);
      final model = record.toBoxModel();
      expect(model.date, record.date);
      expect(listEquals(model.meat, record.points[MajorType.MEAT]), isTrue);
      expect(listEquals(model.fish, record.points[MajorType.FISH]), isTrue);
      expect(listEquals(model.milk, record.points[MajorType.MILK]), isTrue);
      expect(listEquals(model.egg, record.points[MajorType.EGG]), isTrue);
      expect(listEquals(model.soy, record.points[MajorType.SOY]), isTrue);
      expect(listEquals(model.etc, record.points[MajorType.ETC]), isTrue);
    });

    test('fromBoxModel', () {
      final points = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      final record = ProteinRecord.fromList("2020-03-20", pointsList: points);
      final model = RecordModel(
          "2020-03-20", meat4, fish3, milk1, egg1, soy0, etc2_5, false);

      expect(ProteinRecord.fromBoxModel(model), record);
    });
  });
}
