import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/ProteinRecord.dart';
import '../data/RecordClassification.dart';
import '../main.dart';
import '../repository/ProteinRecordRepository.dart';
import '../services/AnalyticsService.dart';
import 'InputViewModel.dart';
import 'InputWidgets.dart';
import 'input_styles.dart';

/// 入力画面
/// [record]にて[ProteinRecord]を受け取り、データを表示
/// [record]にnullは許可されません
/// 戻る際に自動的に保存する
class InputPage extends StatelessWidget {
  InputPage({Key key, @required this.record}) : super(key: key) {
    if (record == null) {
      throw ArgumentError.notNull("record");
    }
  }

  /// レコード
  //non-null
  final ProteinRecord record;

  @override
  Widget build(BuildContext context) {
    final repository =
        Provider.of<ProteinRecordRepository>(context, listen: false);
    return MultiProvider(
      providers: [
        Provider<InputPageBloc>(
            create: (context) => InputPageBloc(),
            dispose: (context, bloc) => bloc.dispose()),
        ChangeNotifierProvider<InputViewModel>(
          create: (context) => InputViewModel(
            record,
            repository: repository,
          ),
        ),
      ],
      // 直下のウィジェットでProviderを使うには、
      // 別のStatelessWidgetを挟んでおかないと行けないらしい
      child: InputScaffold(title: _titleDate()),
    );
  }

  String _titleDate() {
    try {
      final date = DateTime.parse(record.date);
      final format = new DateFormat('yyyy/MM/dd', "ja_JP");
      return format.format(date);
    } on FormatException catch (e) {
      debugPrint("日付フォーマットが間違っています。yyyy-MM-ddで指定して下さい。");
      throw e;
    }
  }
}

/// 入力ページのメインウィジェット
class InputScaffold extends StatelessWidget {
  InputScaffold({Key key, @required this.title}) : super(key: key);
  final String title;

  /// ページ全体
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onBackPressed(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          // 削除アイコン
          actions: <Widget>[
            Consumer<InputViewModel>(
              builder: (context, provider, child) => IconButton(
                key: Key('delete icon'),
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmDialog(context),
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // ヘッダー部分
            _buildHeader(context),
            // 点数表
            Expanded(
              child: _buildCheckSheet(context),
            ),
            // フッター
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  /// ヘッダー部分作成
  Widget _buildHeader(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Expanded(
              child: const Text(""),
            ),
            SizedBox(
              width: 60,
              child: const Center(
                child: const Text(
                  '基本点数',
                  style: headerLabelStyle,
                  textScaleFactor: 1.0,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: const Center(
                child: const Text(
                  '摂取個数',
                  style: headerLabelStyle,
                  textScaleFactor: 1.0,
                ),
              ),
            ),
          ],
        ));
  }

  /// 点数表作成
  Widget _buildCheckSheet(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        final majorType = MajorType.values[index];
        return TypeCardWidget(proteinClassifications[majorType],
            key: Key(majorType.toString()));
      },
      itemCount: proteinClassifications.length,
    );
  }

  /// フッター部分作成
  Widget _buildFooter(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          decoration: footerBoxDecoration,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const Text(
                  "合計点数：",
                  style: footerLabelStyle,
                  textScaleFactor: 1.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Selector<InputViewModel, double>(
                    selector: (context, model) => model.record.totalPoints,
                    builder: (context, totalPoints, child) => Text(
                        totalPoints.toStringAsFixed(1),
                        style: footerLabelStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 削除確認ダイアログ表示
  void _showDeleteConfirmDialog(BuildContext context) {
    // Analytics送信
    final analyticsService = locator<AnalyticsService>();
    analyticsService.sendButtonEvent(buttonName: '削除アイコン');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("削除"),
          content: const Text("この日のデータをすべてクリアします。\nよろしいですか？"),
          actions: <Widget>[
            // ボタン領域
            FlatButton(
              child: const Text("Cancel"),
              onPressed: () => _onDeleteCancel(context),
            ),
            FlatButton(
              child: const Text("OK"),
              onPressed: () => _onDeleteConfirm(context),
            ),
          ],
        );
      },
    );
  }

  /// 削除キャンセル
  void _onDeleteCancel(BuildContext context) {
    // Analytics送信
    final analyticsService = locator<AnalyticsService>();
    analyticsService.sendButtonEvent(buttonName: '削除-キャンセル');

    Navigator.pop(context);
  }

  /// 削除実施
  void _onDeleteConfirm(BuildContext context) {
    // Analytics送信
    final analyticsService = locator<AnalyticsService>();
    analyticsService.sendClearEvent();

    Navigator.pop(context);
    final viewModel = Provider.of<InputViewModel>(context, listen: false);
    final bloc = Provider.of<InputPageBloc>(context, listen: false);
    // データ削除をViewModelに呼び出し
    viewModel.deleteRecord(bloc: bloc);
  }

  /// 画面戻り時の処理
  void _onBackPressed(BuildContext context) {
    final bloc = Provider.of<InputPageBloc>(context, listen: false);
    bloc.returnWithResult();
  }
}
