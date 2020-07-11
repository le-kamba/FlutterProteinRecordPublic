import 'package:package_info/package_info.dart';

class PackageInfoRepository {
  Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  Future<String> getAppName() async {
    final info = await _packageInfo;
    return info.appName;
  }

  Future<String> getVersion() async {
    final info = await _packageInfo;
    return info.version;
  }

  Future<String> getBuildNumber() async {
    final info = await _packageInfo;
    return info.buildNumber;
  }
}
