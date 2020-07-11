import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/data/CalendarData.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';
import 'package:proteinrecord/monthly_page/MonthlyViewModel.dart';

import '../data/dummy_data.dart';

/// MainViewModelクラスのテスト
void main() {
  // リポジトリクラスをモック化
  final mockRepository = MockRecordRepository();
  // ただモック化しただけだと、searchRangeがnullを返してしまうが、本来は有り得ないため、
  // 空リストを返すように上書き
  when(mockRepository.searchRange(
          startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
      .thenAnswer((_) => Future.value([]));
  // 今日を取得するクラスをモック化
  final mockCalendar = MockTodayCalendar();

  group("MonthlyViewModelクラスのテスト", () {
    MonthlyViewModel viewModel;

    setUp(() {
      viewModel = MonthlyViewModel(
          repository: mockRepository, todayCalendar: mockCalendar);
    });

    test('setDisplayDate', () {
      viewModel.setDisplayDate("2020-01-20");
      expect(viewModel.displayDate, "2020-01-20");
    });

    test('firstDayInPage', () {
      viewModel.setDisplayDate("2020-01-20");
      expect(viewModel.firstDayInPage, DateTime(2019, 12, 29));
    });

    test('createCalendarData(set recordList)', () async {
      viewModel.setDisplayDate("2019-06-20");
      await viewModel.createCalendarData();
      expect(viewModel.recordList, isNotNull);
    });

    test('createCalendarData(set cellData)', () async {
      viewModel.setDisplayDate("2019-06-20");
      await viewModel.createCalendarData();
      expect(viewModel.cellData, hasLength(42));

      verify(mockRepository.searchRange(
          startDate: "2019-05-26", endDate: "2019-07-07"));
    });

    test('getFromToYMD', () {
      var result = viewModel.getFromToYMD("2020-01-20");
      expect(result.item1, DateTime(2019, 12, 29));
      expect(result.item2, DateTime(2020, 2, 9));

      result = viewModel.getFromToYMD("2020-12-20");
      expect(result.item1, DateTime(2020, 11, 29));
      expect(result.item2, DateTime(2021, 1, 10));
    });

    test('createCellData', () {
      final logs = List.of([
        //  @formatter:off
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
//    @formatter:on
      ]);

      final list = viewModel.createCellData(DateTime(2019, 12, 29), logs);

      expect(list.length, 42);
      expect(list[0],
          equals(CalendarCellData(DateTime(2019, 12, 29), null)));

      expect(list[1],
          equals(CalendarCellData(DateTime(2019, 12, 30), logs[0])));

      expect(list[2],
          equals(CalendarCellData(DateTime(2019, 12, 31), null)));

      expect(list[3],
          equals(CalendarCellData(DateTime(2020, 1, 1), logs[1])));

      expect(list[41],
          equals(CalendarCellData(DateTime(2020, 2, 8), logs[11])));
    });

    test('isTodayMonth', () {
      viewModel.setDisplayDate("2019-06-20");
      expect(viewModel.isTodayMonth(DateTime(2019, 12, 29)), isFalse);
      expect(viewModel.isTodayMonth(DateTime(2019, 6, 1)), isTrue);
      expect(viewModel.isTodayMonth(DateTime(2020, 6, 20)), isTrue);
    });

    test('isToday', () {
      when(mockCalendar.getToday()).thenReturn(DateTime.parse('2020-01-20'));

      expect(viewModel.isToday(DateTime(2019, 1, 20)), isFalse);
      expect(viewModel.isToday(DateTime(2019, 12, 20)), isFalse);
      expect(viewModel.isToday(DateTime(2020, 1, 20)), isTrue);
    });
  });
}
