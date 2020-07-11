import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../main.dart';
import '../repository/PackageInfoRepository.dart';
import '../services/AnalyticsService.dart';
import 'InfoViewModel.dart';
import 'info_styles.dart';

/// アプリ情報ページ
/// バージョンとビルド番号を表示
/// アプリ名表示
/// プライバシーポリシーページへのリンク
/// ライセンスも出来れば
class InfoPage extends StatelessWidget {
  final PackageInfoRepository packageInfoRepository;

  InfoPage({Key key, @required this.packageInfoRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アプリ情報'),
      ),
      body: ChangeNotifierProvider<InfoViewModel>(
        create: (_) =>
            InfoViewModel(packageInfoRepository: packageInfoRepository),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // アプリ情報
            Container(
              width: double.infinity,
              decoration: listDividerDecoration,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: AppVersion(),
              ),
            ),
            // プラポリンク
            Container(
              width: double.infinity,
              decoration: listDividerDecoration,
              child: Center(
                child: InkWell(
                  onTap: () => {_launchUrl()},
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 20.0,
                      bottom: 20.0,
                    ),
                    child: Text(
                      '規約とプライバシーポリシー',
                      style: listLabelsStyle,
                    ),
                  ),
                ),
              ),
            ),
            // ライセンス?
          ],
        ),
      ),
    );
  }

  /// URLを起動
  void _launchUrl() async {
    // Analytics送信
    final analyticsService = locator<AnalyticsService>();
    analyticsService.sendButtonEvent(buttonName: 'ポリシーページ表示');

    if (await canLaunch(POLICY_URL)) {
      await launch(POLICY_URL);
    } else {
      throw 'Could not launch $POLICY_URL';
    }
  }
}

/// アプリバージョン情報ウィジェット
class AppVersion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.asset(
          'assets/icon/icon.png',
          width: 200,
        ),
        Selector<InfoViewModel, String>(
          selector: (context, model) => model.appName ?? "",
          builder: (context, appName, child) => Text(
            appName,
            style: appNameStyle,
          ),
        ),
        Selector<InfoViewModel, String>(
          selector: (context, model) => model.appVersion,
          builder: (context, version, child) => Text(
            'バージョン $version',
            style: versionStyle,
          ),
        ),
      ],
    );
  }
}
