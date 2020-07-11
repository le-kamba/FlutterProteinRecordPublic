import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './MonthlyViewModel.dart';
import '../data/CalendarData.dart';
import '../lifecycle/LifecycleManager.dart';
import 'monthly_styles.dart';

/// カレンダーウィジェットでライフサイクルを受け取るコールバック
class CalendarLifecycleCallback extends LifecycleCallback {
  final MonthlyViewModel viewModel;

  CalendarLifecycleCallback(this.viewModel);

  @override
  void onResumed() {
    viewModel.updateToday();
  }
}

/// カレンダーウィジェット
class CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MonthlyViewModel>(context, listen: false);
    final _onLifecycleCallback = CalendarLifecycleCallback(viewModel);

    return LifecycleManager(
      callback: _onLifecycleCallback,
      child: Column(
        children: <Widget>[

          /// 曜日ラベルヘッダー
          _buildCalendarHeader(context),

          /// カレンダー本体
          /// todayが変わったらリビルド
          Selector<MonthlyViewModel, DateTime>(
            selector: (context, model) => model.today,
            builder: (context, today, child) => CalendarView(),
          ),
        ],
      ),
    );
  }

  /// ヘッダー(曜日ラベル)作成
  Widget _buildCalendarHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: const Border(
              top: const BorderSide(color: Colors.grey, width: 0.3)),
          color: Colors.blue[50]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          WeekdayLabel(label: '日', color: Colors.red),
          WeekdayLabel(label: '月', color: Colors.grey),
          WeekdayLabel(label: '火', color: Colors.grey),
          WeekdayLabel(label: '水', color: Colors.grey),
          WeekdayLabel(label: '木', color: Colors.grey),
          WeekdayLabel(label: '金', color: Colors.grey),
          WeekdayLabel(label: '土', color: Colors.blue),
        ],
      ),
    );
  }
}

/// カレンダーView
class CalendarView extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MonthlyViewModel>(context, listen: false);

    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.98,
        ),
        physics: new NeverScrollableScrollPhysics(),
        itemCount: 42,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          if (index > 41) return null;
          return InkWell(
            splashColor: Colors.black54,
            key: Key(index.toString()),
            onTap: () => viewModel.navigateNextPage(viewModel.cellData[index]),

            /// セルのデータが変わったらリビルド
            child: Selector<MonthlyViewModel, CalendarCellData>(
                selector: (context, model) =>
                    model.cellData == null ? null : model.cellData[index],
                builder: (context, cellData, child) => CalendarCell(cellData)),
          );
        });
  }
}

/// 曜日用ラベル用ウィジェット
class WeekdayLabel extends StatelessWidget {
  final Color color;
  final String label;

  WeekdayLabel({@required this.label, @required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 18,
      ),
    );
  }
}

/// カレンダーセル用ウィジェット
class CalendarCell extends StatelessWidget {
  final CalendarCellData _calendarCellData;

  CalendarCell(this._calendarCellData);

  @override
  Widget build(BuildContext context) {
    if (_calendarCellData == null) return Container();
    final total = _calendarCellData.getTotalPoint();
    final viewModel = Provider.of<MonthlyViewModel>(context, listen: false);

    return Container(
      decoration: viewModel.isToday(_calendarCellData.calendar)
          ? todayBackground
          : viewModel.isTodayMonth(_calendarCellData.calendar)
              ? todayMonthBackground
              : otherMonthBackground,
      child: Stack(
        children: <Widget>[
          // 左上寄せで日付文字列
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Text(
                _calendarCellData.calendar.day.toString(),
                style: viewModel.isTodayMonth(_calendarCellData.calendar)
                    ? todayMonthTextStyle
                    : otherMonthTextStyle,
              ),
            ),
          ),
          // センタリングでたんぱく質合計点数
          Align(
            alignment: AlignmentDirectional.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  total.toStringAsFixed(1),
                  style: total > 0.0 ? pointTextStyle : zeroPointTextStyle,
                ),
                // 11点以上はThumbsUpアイコン表示
                _calendarCellData.isAchieved()
                    ? const Icon(
                        Icons.thumb_up,
                        size: 12.0,
                        color: Colors.deepOrange,
                      )
                    : const SizedBox(
                        height: 1,
                        width: 1,
                      ),
              ],
            ),
          ),

          // ワークアウトアイコン表示
          /*_calendarCellData.wentWorkout()
              ? Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: const Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 12.0,
                      color: Colors.purple,
                    ),
                  ),
                )
              : */
          SizedBox(
            height: 1,
            width: 1,
          ),
        ],
      ),
    );
  }
}
