import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';
import 'package:proteinrecord/data/database.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';

import '../data/dummy_data.dart';

/// Hiveの初期化
Future<void> initialiseHive() async {
  final path = Directory.current.path;
  Hive
    ..init(path)
    ..registerAdapter(RecordModelAdapter());

  Hive.deleteFromDisk(); // 常に空の状態で開始する
}

/// ProteinRecordRepositoryクラスのテスト
void main() async {
  await initialiseHive();

  group("ProteinRecordRepositoryクラスのテスト", () {
    ProteinRecordRepository repository;

    setUp(() {
      repository = ProteinRecordRepository(RecordModelBox());
    });
    tearDown(() async {
      // 最後に必ずクリア
      await Hive.deleteFromDisk();
    });

    test('save/fetchAll', () async {
      final points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      final record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      repository.save(record);
      final list = await repository.fetchAll();
      expect(list, [record]);
    });

    test('get', () async {
      final points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      final record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      repository.save(record);
      final item = await repository.get("2020-02-20");
      expect(item, record);
    });

    test('delete', () async {
      final points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      final record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await repository.save(record);
      await repository.deleteAll();
      final list = await repository.fetchAll();
      expect(list, []);
      final item = await repository.get("2020-02-20");
      expect(item, isNull);
    });

    test('update', () async {
      final points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      final points2 = List.of([
        [...meat3],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc2_5],
      ]);
      final record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      await repository.save(record);

      final record2 = ProteinRecord.fromList("2020-02-20", pointsList: points2);
      await repository.save(record2);

      final list = await repository.fetchAll();
      expect(list, [record2]);
    });

    test('onedelete', () async {
      final points = List.of([
        [...meat4],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc0_5],
      ]);
      final points2 = List.of([
        [...meat3],
        [...fish3],
        [...milk1],
        [...egg1],
        [...soy1_5],
        [...etc2_5],
      ]);
      final record = ProteinRecord.fromList("2020-02-20", pointsList: points);
      final record2 = ProteinRecord.fromList("2020-02-22", pointsList: points2);
      await repository.save(record);
      await repository.save(record2);

      await repository.delete(record.date);
      final list = await repository.fetchAll();
      expect(list, [record2]);
    });

    test('searchRangeのFormat例外スロー:startDate', () async {
      expect(() =>
          repository.searchRange(
              startDate: "2020/02/01", endDate: "2020-02-29"),
          throwsFormatException);
    });

    test('searchRangeのFormat例外スロー:endDate', () async {
      expect(() =>
          repository.searchRange(
              startDate: "2020-02-01", endDate: "2020/02/29"),
          throwsFormatException);
    });

    test('searchRange', () async {
      final logs = [
//  @formatter:off
       ProteinRecord.fromPoints("2019-12-28",
       meatPoints: meat3, fishPoints: fish3, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy0_5, etcPoints: etc3),
       ProteinRecord.fromPoints("2019-12-29",
       meatPoints: meat3, fishPoints: fish2_5, milkPoints: milk2, eggPoints: egg1,
       soyPoints: soy0_5, etcPoints: etc3),
       ProteinRecord.fromPoints("2019-12-30",
       meatPoints: meat3, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy0_5, etcPoints: etc3),
       ProteinRecord.fromPoints("2020-01-01",
       meatPoints: meat2, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy0_5, etcPoints: etc2_5),
       ProteinRecord.fromPoints("2020-01-02",
       meatPoints: meat2, fishPoints: fish3, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy0_5, etcPoints: etc2_5),
       ProteinRecord.fromPoints("2020-01-03",
       meatPoints: meat3, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc2_5),
       ProteinRecord.fromPoints("2020-01-08",
       meatPoints: meat3, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-01-10",
       meatPoints: meat2, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-01-21",
       meatPoints: meat1, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-01-22",
       meatPoints: meat5, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-01-23",
       meatPoints: meat4, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-01-24",
       meatPoints: meat3_5, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-01-31",
       meatPoints: meat2_5, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-02-08",
       meatPoints: meat1_5, fishPoints: fish2_5, milkPoints: milk1_5, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
       ProteinRecord.fromPoints("2020-02-09",
       meatPoints: meat1_5, fishPoints: fish3, milkPoints: milk2, eggPoints: egg1,
       soyPoints: soy1_5, etcPoints: etc0_5),
//    @formatter:on
      ];

      await repository.addAll(logs);
      final all = await repository.fetchAll();
      expect(all.length, logs.length);

      final list = await repository.searchRange(
          startDate: '2019-12-29', endDate: '2020-02-09');
      expect(list.length, 13);
    });
  });
}
