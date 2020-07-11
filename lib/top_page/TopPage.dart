import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../data/TodayCalendar.dart';
import '../main.dart';
import '../monthly_page/MonthlyPage.dart';
import '../services/AnalyticsService.dart';
import '../services/NavigationService.dart';
import 'TopViewModel.dart';
import 'Updater.dart';

/// TopPage
class TopPage extends StatelessWidget {
  static const String TITLE_TOP = 'たんぱく録';

  final String date;
  final TodayCalendar todayCalendar;

  TopPage({Key key, this.date, this.todayCalendar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 画面の描画が終わったタイミングで表示させる
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
    return Scaffold(
        appBar: AppBar(
          title: Text(TITLE_TOP),
          actions: <Widget>[
            IconButton(
              key: Key('info icon'),
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoPage(),
            ),
          ],
        ),
        body: Provider<TopPageBloc>(
          create: (context) => TopPageBloc(),
          dispose: (context, bloc) => bloc.dispose(),
          child: Stack(
            children: <Widget>[
              Pager(date: date),
              Updater(todayCalendar: todayCalendar,),
            ],
          ),
        ));
  }

  /// Infoページへの移動
  void _showInfoPage() {
    // Analytics送信
    final analyticsService = locator<AnalyticsService>();
    analyticsService.sendButtonEvent(buttonName: '情報アイコン');

    final navigationService = locator<NavigationService>();
    navigationService.navigateTo(RoutePathName.INFO);
  }

  /// チュートリアルページ表示
  void _showTutorial() async {
    final preference = await SharedPreferences.getInstance();
    // 最初の起動ならチュートリアル表示
    if (preference.getBool(PreferenceKey.TUTORIAL_DONE) != true) {
      // ルート遷移
      // ※まだProviderは使えないのでここでやる
      final NavigationService _navigationService = locator<NavigationService>();
      _navigationService.navigateTo(RoutePathName.TUTORIAL);
    }
  }
}

/// Pager(メインのView Pager部分)
class Pager extends StatefulWidget {
  final String date;

  Pager({Key key, this.date}) : super(key: key);

  @override
  State<Pager> createState() => _PageViewState();
}

class _PageViewState extends State<Pager> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<TopPageBloc>(context, listen: false);

    return PageView(
      controller: bloc.pageController,
      onPageChanged: (index) => bloc.onPageChanged(index),
      children: [
        // 前月を表示
        MonthlyPage(
          date: _prevMonth(widget.date),
          index: -1,
        ),
        // 当月を表示
        MonthlyPage(
          date: widget.date,
          index: 0,
        ),
      ],
    );
  }

  /// 前月を計算する
  String _prevMonth(String date) {
    var jiffyDate = Jiffy(date);
    jiffyDate.subtract(months: 1);
    // DateTimeがparse出来るフォーマットで返す
    return jiffyDate.format('yyyy-MM-dd');
  }
}
