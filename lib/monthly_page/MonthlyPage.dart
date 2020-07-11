import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:proteinrecord/repository/ProteinRecordRepository.dart';
import 'package:proteinrecord/top_page/TopViewModel.dart';
import 'package:provider/provider.dart';

import 'MonthlyViewModel.dart';
import 'MonthlyWidgets.dart';

/// メイン画面(起動画面)
/// [date]にて日付を文字列(yyyy-MM-dd)で受け取り、その年月のデータを表示
class MonthlyPage extends StatelessWidget {
  MonthlyPage({Key key, this.date, @required this.index}) : super(key: key);

  final String date;
  final int index;

  @override
  Widget build(BuildContext context) {
    final repository =
        Provider.of<ProteinRecordRepository>(context, listen: false);
    return ChangeNotifierProvider<MonthlyViewModel>(
      create: (context) =>
          MonthlyViewModel.withDisplayDate(date, repository: repository),
      child: _buildPage(context),
    );
  }

  /// ページ全体
  Widget _buildPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        /// ヘッダー部
        _buildHeader(context),

        /// カレンダー部
        Flexible(
          flex: 4,
          child: Selector<MonthlyViewModel, bool>(
            selector: (context, model) => model.showLoading,
            builder: (context, showLoading, child) =>
                showLoading ? _buildLoadingProgress(context) : CalendarWidget(),
          ),
        ),

        /// フッター
        Flexible(
          flex: 1,
          child: Center(child: _buildFooter(context)),
        ),
      ],
    );
  }

  /// ローディングの表示
  Widget _buildLoadingProgress(BuildContext context) {
    return Container(
      color: const Color.fromARGB(80, 80, 80, 80),
      child: const Center(
        child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    initializeDateFormatting('ja');
    var format = new DateFormat.yMMM('ja');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(6),
          child: _buildLeftArrow(context),
        ),

        /// 年月表示ラベル
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Selector<MonthlyViewModel, String>(
            selector: (context, model) => model.displayDate,
            builder: (context, date, child) => Text(
              format.format(DateTime.parse(date)),
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),

        /// 翌月表示ボタン
        Padding(
          padding: const EdgeInsets.all(6),
          child: _buildRightArrow(context),
        ),
      ],
    );
  }

  static const footerLabel1 = '毎日12点を目指して\nがんばろう';
  static const footerLabel2 = '3食4点ずつ\nバランス良く';

  /// フッター表示
  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.orange[50],
          border: Border.all(color: Colors.black87, width: 0.3),
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          index == 0 ? footerLabel1 : footerLabel2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLeftArrow(BuildContext context) {
    final bloc = Provider.of<TopPageBloc>(context, listen: false);

    if (index >= 0) {
      return IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => bloc.onPageMove(-1),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: const SizedBox(
          width: 24.0,
        ),
      );
    }
  }

  Widget _buildRightArrow(BuildContext context) {
    final bloc = Provider.of<TopPageBloc>(context, listen: false);

    if (index < 0) {
      return IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: () => bloc.onPageMove(1),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: const SizedBox(
          width: 24.0,
        ),
      );
    }
  }
}
