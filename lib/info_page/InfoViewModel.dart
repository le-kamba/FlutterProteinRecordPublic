import 'package:flutter/material.dart';

import '../repository/PackageInfoRepository.dart';

/// 情報ページViewModel
class InfoViewModel with ChangeNotifier {
  String appName;
  String appVersion;

  final PackageInfoRepository packageInfoRepository;

  /// コンストラクタ
  InfoViewModel({@required this.packageInfoRepository}) {
    getPackageInfo();
  }

  /// アプリ名などを取得
  @visibleForTesting
  Future<void> getPackageInfo() async {
    appName = await packageInfoRepository.getAppName();
    final version = await packageInfoRepository.getVersion();
    final buildNumber = await packageInfoRepository.getBuildNumber();
    appVersion = "$version ($buildNumber)";

    notifyListeners();
  }
}
