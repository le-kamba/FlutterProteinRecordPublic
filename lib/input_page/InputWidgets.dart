import 'package:flutter/material.dart';
import 'package:proteinrecord/input_page/InputViewModel.dart';
import 'package:provider/provider.dart';

import '../data/RecordClassification.dart';
import 'input_styles.dart';

/// 区分別カード用ウィジェット
class TypeCardWidget extends StatelessWidget {
  TypeCardWidget(this.majorType, {Key key}) : super(key: key);

  final MajorClassification majorType;

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: InkWell(
        onTap: () => debugPrint("Card tapped.$key"),
        child: Row(
          children: <Widget>[
            Container(
              height: minorRowHeight * majorType.minors.length,
              width: majorRowWidth,
              color: majorType.color,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 3.0, right: 2.0),
                  child: Text(
                    majorType.name,
                    style: TextStyle(fontSize: 18.0),
                    textScaleFactor: 1.0,
                  ),
                ),
              ),
            ),

            // データ行ウィジェット
            Expanded(
              child: TypeBoard(majorType),
            ),
          ],
        ),
      ),
    );
  }
}

/// 大分類ラベルを除いた小分類行を載せるレイアウト部分のウィジェット
class TypeBoard extends StatelessWidget {
  TypeBoard(this.majorType);

  final MajorClassification majorType;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Container(
            height: minorRowHeight,
            decoration: BoxDecoration(
              border: typeRowBorderStyle(context, index),
            ),
            child: TypeRow(majorType.typeKey, majorType.minors[index], index));
      },
      itemCount: majorType.minors.length,
    );
  }
}

/// データ行ウィジェット
class TypeRow extends StatelessWidget {
  TypeRow(this.majorType, this.minorType, this.minorIndex);

  final MajorType majorType;
  final int minorIndex;
  final MinorClassification minorType;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InputViewModel>(context, listen: false);
    final bloc = Provider.of<InputPageBloc>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // 項目ラベル
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 6.0, top: 6.0, bottom: 6.0),
            child: Text(
              "${minorType.name} ${minorType.notes ?? ''}\n${minorType.description}",
              style: minorLabelStyle,
              textScaleFactor: 1.0,
            ),
          ),
        ),
        // 画像
        Image.asset(
          minorType.imageAssetName,
          width: 36,
        ),
        // 基本点数
        Padding(
          padding: EdgeInsets.only(left: 12.0, right: 6.0),
          child: Text(
            minorType.basePoint.toStringAsFixed(1),
            style: basePointLabelStyle,
            textScaleFactor: 1.0,
          ),
        ),
        // -ボタン
        Padding(
          padding: EdgeInsets.only(left: 1.0),
          child: IconButton(
            key: Key('down:${majorType.toString()}.$minorIndex'),
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () =>
                viewModel.countDown(majorType, minorIndex, bloc: bloc),
          ),
        ),
        // 現在点数
        SizedBox(
          width: 18.0,
          child: Selector<InputViewModel, int>(
            selector: (context, model) => model.record.points == null
                ? 0
                : model.record.points[majorType] == null
                    ? 0
                    : model.record.points[majorType][minorIndex],
            builder: (context, count, child) => Text(
              count.toString(),
              key: Key('count:${majorType.toString()}.$minorIndex'),
              style: countLabelStyle,
              textScaleFactor: 1.0,
            ),
          ),
        ),
        // +ボタン
        Padding(
          padding: EdgeInsets.only(),
          child: IconButton(
            key: Key('up:${majorType.toString()}.$minorIndex'),
            icon: Icon(Icons.add_circle_outline),
            onPressed: () =>
                viewModel.countUp(majorType, minorIndex, bloc: bloc),
          ),
        ),
      ],
    );
  }
}
