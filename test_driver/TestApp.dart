import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/main.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';
import 'package:proteinrecord/services/AnalyticsService.dart';
import 'package:proteinrecord/services/NavigationService.dart';
import 'package:proteinrecord/services/VersionCheckService.dart';
import 'package:provider/provider.dart';

/// Mock ProteinRecordRepository
class MockRecordRepository extends Mock implements ProteinRecordRepository {}

/// MockAnalytics
class MockAnalyticsService extends Mock implements AnalyticsService {}

void setupLocator({VersionCheckService versionCheckService}) {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton<AnalyticsService>(() => MockAnalyticsService());
  locator.registerLazySingleton<VersionCheckService>(() => versionCheckService);
}

void testMain(VersionCheckService versionCheckService) async {
  setupLocator(versionCheckService: versionCheckService);

  // 描画の開始
  runApp(Provider<ProteinRecordRepository>(
    create: (context) => MockRecordRepository(),
    dispose: (context, bloc) => bloc.dispose(),
    child: MyApp(),
  ));
}
