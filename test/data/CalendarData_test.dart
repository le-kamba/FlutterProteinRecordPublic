import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:proteinrecord/data/CalendarData.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';

import 'dummy_data.dart';

/// ProteinRecordクラスのテスト
void main() {
  group("CalendarCellDataクラスのテスト", () {
    test('operator ==', () {
      var points = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      var record1 = ProteinRecord.fromList("2020-03-20", pointsList: points);
      var record2 = ProteinRecord.fromList("2020-03-20", pointsList: points);
      var celldata1 = CalendarCellData(DateTime(2020, 3, 20), record1);
      var celldata2 = CalendarCellData(DateTime(2020, 3, 20), record2);
      expect(celldata1 == celldata2, isTrue);
    });

    test('getTotalPoint', () {
      var points = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      var record = ProteinRecord.fromList("2020-03-20", pointsList: points);
      var celldata1 = CalendarCellData(DateTime(2020, 3, 20), record);
      expect(celldata1.getTotalPoint(), equals(11.5));

      var celldata2 = CalendarCellData(DateTime(2020, 3, 20), null);
      expect(celldata2.getTotalPoint(), equals(0.0));
    });

    test('isAchieved', () {
      var points = List.of([meat4, fish3, milk1, egg1, soy0, etc2_5]);
      var record = ProteinRecord.fromList("2020-03-20", pointsList: points);
      var celldata1 = CalendarCellData(DateTime(2020, 3, 20), record);
      expect(celldata1.isAchieved(), isTrue);

      var celldata2 = CalendarCellData(DateTime(2020, 3, 20), null);
      expect(celldata2.isAchieved(), isFalse);

      var points3 = List.of([meat0, fish3, milk1, egg1, soy0, etc2_5]);
      var record3 = ProteinRecord.fromList("2020-03-20", pointsList: points3);
      var celldata3 = CalendarCellData(DateTime(2020, 3, 20), record3);
      expect(celldata3.isAchieved(), isFalse);
    });
  });
}
