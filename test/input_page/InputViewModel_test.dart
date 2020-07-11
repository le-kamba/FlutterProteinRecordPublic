import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/data/ProteinRecord.dart';
import 'package:proteinrecord/data/RecordClassification.dart';
import 'package:proteinrecord/input_page/InputViewModel.dart';

import '../data/dummy_data.dart';

/// InputViewModelクラスのテスト
void main() {
  final record = ProteinRecord.fromPoints("2020-02-22",
      meatPoints: meat3,
      fishPoints: fish0,
      milkPoints: milk1,
      eggPoints: egg1,
      soyPoints: soy1,
      etcPoints: etc2_5);

  // リポジトリクラスはモックを使う
  // dartのMockは暗黙的インターフェースを使うとすべてのメソッドがmock化される
  final mockRepository = MockRecordRepository();
  when(mockRepository.save(any)).thenAnswer((_) async => Future.value());

  group("InputViewModelクラスのコンストラクタのテスト", () {
    test("コンストラクタ_正常_ProteinRecord", () {
      InputViewModel viewModel = InputViewModel(
          ProteinRecord("2020-02-22", null),
          repository: mockRepository);
      expect(viewModel, isNotNull);
    });
    test("コンストラクタ_record_null", () {
      expect(() => InputViewModel(null, repository: mockRepository),
          throwsArgumentError);
    });
  });

  group("InputViewModelクラスの関数のテスト", () {
    InputViewModel viewModel;
    InputPageBloc bloc;

    setUp(() {
      viewModel = InputViewModel(
          ProteinRecord.fromPoints(record.date,
              meatPoints: [...record.points[MajorType.MEAT]],
              fishPoints: [...record.points[MajorType.FISH]],
              milkPoints: [...record.points[MajorType.MILK]],
              eggPoints: [...record.points[MajorType.EGG]],
              soyPoints: [...record.points[MajorType.SOY]],
              etcPoints: [...record.points[MajorType.ETC]]),
          repository: mockRepository);

      bloc = InputPageBloc();

      expect(bloc.isModified, isFalse);
    });

    test("カウントアップ_0to1", () {
      expect(viewModel.record.points[MajorType.FISH][3], 0);
      expect(viewModel.record.totalPoints, 8.5);
      viewModel.countUp(MajorType.FISH, 3, bloc: bloc);
      expect(viewModel.record.points[MajorType.FISH][3], 1);
      expect(viewModel.record.totalPoints, 9.0);
      expect(bloc.isModified, isTrue);
      verify(mockRepository.save(any));
    });

    test("カウントダウン_1to0", () {
      expect(viewModel.record.points[MajorType.MILK][0], 1);
      expect(viewModel.record.totalPoints, 8.5);
      viewModel.countDown(MajorType.MILK, 0, bloc: bloc);
      expect(viewModel.record.points[MajorType.MILK][0], 0);
      expect(viewModel.record.totalPoints, 7.5);
      expect(bloc.isModified, isTrue);
      verify(mockRepository.save(any));
    });

    test("カウントダウン_0to0", () {
      expect(viewModel.record.points[MajorType.MILK][1], 0);
      expect(viewModel.record.totalPoints, 8.5);
      viewModel.countDown(MajorType.MILK, 1, bloc: bloc);
      expect(viewModel.record.points[MajorType.MILK][1], 0);
      expect(viewModel.record.totalPoints, 8.5);
      expect(bloc.isModified, isFalse);
    });

    test("削除", () {
      expect(viewModel.record.totalPoints, 8.5);
      viewModel.deleteRecord(bloc: bloc);
      expect(viewModel.record.totalPoints, 0.0);
      expect(bloc.isModified, isTrue);
      verify(mockRepository.save(any));
    });
  });

  test("カウント_9to9", () {
    InputViewModel viewModel;
    InputPageBloc bloc;

    viewModel = InputViewModel(
        ProteinRecord.fromPoints(record.date,
            meatPoints: [...meat3],
            fishPoints: [...fish0],
            milkPoints: [...milk1],
            eggPoints: [9],
            soyPoints: [...soy1],
            etcPoints: [...etc2_5]),
        repository: mockRepository);

    bloc = InputPageBloc();

    expect(bloc.isModified, isFalse);
    expect(viewModel.record.points[MajorType.EGG][0], 9);

    viewModel.countUp(MajorType.EGG, 0, bloc: bloc);
    expect(viewModel.record.points[MajorType.EGG][0], 9);

    expect(bloc.isModified, isFalse);
  });
}
