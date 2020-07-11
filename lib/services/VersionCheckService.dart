import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

/// Firebase RemoteConfigを使い、アプリの最新バージョンと比較するサービス
class VersionCheckService {
  /// 最新ポリシーバージョン保持用
  int _newPolicyVersion;

  /// 最新ポリシーバージョンgetter
  int get newPolicyVersion => _newPolicyVersion;

  /// ポリシー更新フラグ
  bool _needPolicyAgreement;

  /// ポリシー更新フラグgetter
  bool get needPolicyAgreement => _needPolicyAgreement;

  /// アプリ更新フラグ
  bool _needUpdate = false;

  /// アプリ更新フラグgetter
  bool get needUpdate => _needUpdate;

  /// アプリバージョンチェック
  static const String DEV_VERSION_CONFIG = "dev_app_version";
  static const String VERSION_CONFIG = "force_update_app_version";

  /// ポリシーバージョンチェック
  static const POLICY_VERSION_CONFIG = "policy_version";
  static const DEV_POLICY_CONFIG = "dev_policy_version";

  bool get isDebug => !bool.fromEnvironment('dart.vm.product');

  /// バージョンチェック関数
  /// アプリの強制アップデートバージョンと、利用規約バージョンをFirebase RemoteConfigから取得して比較する
  Future<bool> versionCheck() async {
    // remote config
    final remoteConfig = await RemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: isDebug));
    final cacheTime = isDebug ? Duration(seconds: 2) : Duration(hours: 6);

    try {
      // 何度も取得するのを防ぐため、一定時間キャッシュさせる
      await remoteConfig.fetch(expiration: cacheTime);
      await remoteConfig.activateFetched();

      // ポリシーバージョン比較
      _needPolicyAgreement = await _checkPolicyVersion(remoteConfig);

      // アプリバージョン比較
      _needUpdate = await _checkAppUpdate(remoteConfig);

      return true;
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    return false;
  }

  /// アプリ強制更新チェック
  Future<bool> _checkAppUpdate(RemoteConfig remoteConfig) async {
    // versionCode(buildNumber)取得
    final PackageInfo info = await PackageInfo.fromPlatform();
    int currentVersion = int.parse(info.buildNumber);
    // releaseビルドかどうかで取得するconfig名を変更
    final configName = isDebug ? DEV_VERSION_CONFIG : VERSION_CONFIG;

    // アプリバージョン比較
    int newVersion = remoteConfig.getInt(configName);
    debugPrint("newVersion=$newVersion");
    if (newVersion > currentVersion) {
      return true;
    }
    return false;
  }

  /// 利用規約バージョンチェック
  Future<bool> _checkPolicyVersion(RemoteConfig remoteConfig) async {
    final policyConfigName =
        isDebug ? DEV_POLICY_CONFIG : POLICY_VERSION_CONFIG;

    // ポリシーバージョンを取得
    _newPolicyVersion = remoteConfig.getInt(policyConfigName);
    debugPrint("newPolicyVersion=$newPolicyVersion");
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();

    int agreeVersion =
        sharedPreference.getInt(PreferenceKey.POLICY_AGREE_VERSION) ?? 0;
    debugPrint("agreeVersion=$agreeVersion");
    if (_newPolicyVersion > agreeVersion) {
      return true;
    }
    return false;
  }
}
