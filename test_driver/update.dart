import 'package:flutter_driver/driver_extension.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/constants.dart';
import 'package:proteinrecord/services/VersionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'TestApp.dart';

/// VersionCheck
class MockVersionCheckService extends Mock implements VersionCheckService {
  @override
  Future<bool> versionCheck() async {
    return true;
  }

  @override
  bool get needPolicyAgreement => true;

  @override
  bool get needUpdate => true;
}

void main() {
  // チュートリアル表示済みにする
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({PreferenceKey.TUTORIAL_DONE: true});

  enableFlutterDriverExtension();
  testMain(MockVersionCheckService());
}
