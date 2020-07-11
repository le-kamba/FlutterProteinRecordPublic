import 'package:mockito/mockito.dart';
import 'package:proteinrecord/data/TodayCalendar.dart';
import 'package:proteinrecord/repository/PackageInfoRepository.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';
import 'package:proteinrecord/services/AnalyticsService.dart';
import 'package:proteinrecord/services/VersionCheckService.dart';

///DummyData
///
final meat5 = [1, 0, 2, 0];
final meat4 = [1, 0, 1, 0];
final meat3_5 = [1, 0, 0, 1];
final meat3 = [1, 0, 0, 0];
final meat2 = [0, 0, 2, 0];
final meat2_5 = [0, 1, 1, 0];
final meat1_5 = [0, 1, 0, 0];
final meat1 = [0, 0, 1, 0];
final meat0 = [0, 0, 0, 0];

final fish4 = [1, 1, 1, 1];
final fish3 = [1, 1, 0, 0];
final fish2_5 = [1, 0, 0, 1];
final fish1 = [0, 1, 0, 0];
final fish0 = [0, 0, 0, 0];

final egg1 = [1];
final egg0 = [0];

final milk1_5 = [1, 1, 0];
final milk2 = [1, 1, 1];
final milk1 = [1, 0, 0];
final milk0 = [0, 0, 0];

final soy1 = [1, 0, 0, 0];
final soy2 = [1, 1, 0, 0];
final soy0 = [0, 0, 0, 0];
final soy0_5 = [0, 0, 1, 0];
final soy1_5 = [0, 1, 1, 0];

final etc0_5 = [1, 0];
final etc3 = [1, 1];
final etc2_5 = [0, 1];

///// Mock RecordModelBox
//class MockRecordModelBox extends Mock implements RecordModelBox {}
//
///// Mock Box
//class MockBox<T> extends Mock implements Box<T> {}

/// Mock ProteinRecordRepository
class MockRecordRepository extends Mock implements ProteinRecordRepository {}

/// Mock TodayCalendar
class MockTodayCalendar extends Mock implements TodayCalendar {}

/// MockAnalytics
class MockAnalyticsService extends Mock implements AnalyticsService {}

/// VersionCheck
class FalseMockVersionCheckService extends Mock implements VersionCheckService {
  @override
  Future<bool> versionCheck() async {
    return true;
  }

  @override
  bool get needPolicyAgreement => false;

  @override
  bool get needUpdate => false;
}

/// VersionCheck
class MockVersionCheckService extends Mock implements VersionCheckService {}

/// PackageInfo
class MockPackageRepository extends Mock implements PackageInfoRepository {}
