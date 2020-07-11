import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../data/TodayCalendar.dart';
import '../main.dart';
import '../services/AnalyticsService.dart';
import '../services/NavigationService.dart';
import '../services/VersionCheckService.dart';
import 'PlatformAlertDialog.dart';

/// 強制アップデートダイアログを出す為のダミーに近いStatefulWidget
class Updater extends StatefulWidget {
  Updater({Key key, this.todayCalendar}) : super(key: key);

  final TodayCalendar todayCalendar;

  @override
  State<StatefulWidget> createState() => _UpdaterState();
}

class _UpdaterState extends State<Updater> with WidgetsBindingObserver {
  final NavigationService _navigationService = locator<NavigationService>();

  final _checker = locator<VersionCheckService>();

  DateTime get _today => widget.todayCalendar == null
      ? TodayCalendar().getToday()
      : widget.todayCalendar.getToday();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // バージョンチェック
      _checkVersions(context);
    }
  }

  /// 各種バージョンチェック
  void _checkVersions(BuildContext context) async {
    final result = await _checker.versionCheck();
    await _doneCheck(context, result);
  }

  @override
  Widget build(BuildContext context) {
    // 画面の描画が終わったタイミングで実行
    // 初回起動時や他の画面から戻ったときはresumeではなくこちらが呼ばれる
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkVersions(context));

    // ダミーのウィジェット
    return SizedBox(
      width: 1,
    );
  }

  /// チェック後の振り分け
  Future<void> _doneCheck(BuildContext context, bool result) async {
    // チェック処理自体が失敗している場合はエラー。
    if (!result) {
      await _showErrorDialog(context);
      return;
    }
    if (_checker.needPolicyAgreement) {
      // 利用規約同意が必要
      _showAgreementDialog(context);
    } else if (_checker.needUpdate) {
      // アプリ更新が必要
      _showUpdateDialog(context);
    }
  }

  Future<void> _showErrorDialog(BuildContext context) async {
    final sharedPreference = await SharedPreferences.getInstance();
    final lastDateStr =
        sharedPreference.getString(PreferenceKey.VERSIONS_CHECK_LAST_DATE);
    final lastDate = lastDateStr != null
        ? DateTime.parse(lastDateStr)
        : _today.subtract(Duration(days: 15));
    final safeDate = lastDate.add(Duration(days: 10));

    // 初回起動時はエラー
    // 前回チェックから10日経っていたらエラー
    if (safeDate.compareTo(_today) <= 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
            child: _createPlatformAlertDialogError(context),
            onWillPop: () async => false,
          );
        },
      );
      sharedPreference.setString(
          PreferenceKey.VERSIONS_CHECK_LAST_DATE, _today.toString());
    }
  }

  /// 更新版案内ダイアログを表示
  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          child: _createPlatformAlertDialogUpdate(),
          onWillPop: () async => false,
        );
      },
    );
  }

  /// アップデートダイアログ作成
  Widget _createPlatformAlertDialogUpdate() {
    final title = "バージョン更新のお知らせ";
    final message = "新しいバージョンのアプリが利用可能です。ストアより更新版を入手して、ご利用下さい。";
    final btnLabel = "今すぐ更新";

    return PlatformAlertDialog(
      key: Key('update dialog'),
      title: title,
      message: message,
      actions: <Widget>[
        FlatButton(
          child: Text(
            btnLabel,
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () => _launchStore(),
        ),
      ],
    ).build();
  }

  /// 指定のURLを起動する. App Store or Play Storeのリンク
  void _launchStore() async {
    final storeUrl = Platform.isIOS ? APP_STORE_URL : PLAY_STORE_URL;

    if (await canLaunch(storeUrl)) {
      await launch(storeUrl);
    } else {
      throw 'Could not launch $storeUrl';
    }
  }

  /// ポリシー同意ダイアログ表示
  void _showAgreementDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          child: _createPlatformAlertDialogPolicy(context),
          onWillPop: () async => false,
        );
      },
    );
  }

  /// ポリシー同意ダイアログ作成
  Widget _createPlatformAlertDialogPolicy(BuildContext context) {
    final title = "利用規約";
    final btnLabel = "同意する";
    final width = MediaQuery.of(context).size.width;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      key: Key('policy dialog'),
      title: Text(title),
      content: Container(
        width: width * 0.8,
        child: InAppWebView(
          initialUrl: POLICY_URL,
          shouldOverrideUrlLoading: (controller, request) =>
              _shouldOverrideUrlLoading(controller, request),
          initialOptions: InAppWebViewWidgetOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: false,
              clearCache: true,
              useShouldOverrideUrlLoading: true,
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            btnLabel,
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () => _onAgreement(context),
        ),
      ],
    );
  }

  /// 外部URL遷移を拾ってブラウザを起動する
  Future<ShouldOverrideUrlLoadingAction> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      ShouldOverrideUrlLoadingRequest request) async {
    final requestUrl = request.url;
    _launchUrl(requestUrl);
    return ShouldOverrideUrlLoadingAction.CANCEL;
  }

  /// 指定のURLを起動する. App Store or Play Storeのリンク
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// 同意後処理
  void _onAgreement(BuildContext context) async {
    // 同意済みを保存
    final pref = await SharedPreferences.getInstance();
    pref.setInt(PreferenceKey.POLICY_AGREE_VERSION, _checker.newPolicyVersion);
    // Analytics開始
    final analyticsService = locator<AnalyticsService>();
    analyticsService.sendAgreementEvent();

    // ダイアログを閉じる
    _navigationService.goBack();

    // 更新が必要でチュートリアルが終わっている場合直ぐに表示
    if (pref.getBool(PreferenceKey.TUTORIAL_DONE) == true &&
        _checker.needUpdate) {
      _showUpdateDialog(context);
    }
  }

  /// エラーダイアログ
  Widget _createPlatformAlertDialogError(BuildContext context) {
    final title = "エラー";
    final message = "サーバーと接続できませんでした。通信環境をご確認の上、もう一度お試し下さい。";
    final btnLabel = "再試行";

    return PlatformAlertDialog(
      key: Key('error dialog'),
      title: title,
      message: message,
      actions: <Widget>[
        FlatButton(
          child: Text(
            btnLabel,
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            // ダイアログを閉じる
            _navigationService.goBack();
            // 再試行
            _checkVersions(context);
          },
        ),
      ],
    ).build();
  }
}
