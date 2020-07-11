import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/info_page/InfoViewModel.dart';

import '../data/dummy_data.dart';

/// InfoViewModelクラスのテスト
void main() {
  final mockRepository = MockPackageRepository();
  when(mockRepository.getAppName()).thenAnswer((_) => Future.value("AppName"));
  when(mockRepository.getBuildNumber()).thenAnswer((_) => Future.value("3"));
  when(mockRepository.getVersion()).thenAnswer((_) => Future.value("1.0.0"));

  group("InfoViewModelクラスのコンストラクタのテスト", () {
    test("getPackageInfo", () async {
      InfoViewModel viewModel =
          InfoViewModel(packageInfoRepository: mockRepository);
      expect(viewModel, isNotNull);

      await viewModel.getPackageInfo();
      expect(viewModel.appName, "AppName");
      expect(viewModel.appVersion, "1.0.0 (3)");
    });
  });
}
