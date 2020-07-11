import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 入力ページ向けスタイル定義
///

/// ヘッダーラベル文字スタイル
const headerLabelStyle = TextStyle(fontSize: 14);

/// フッターラベル文字スタイル
const footerLabelStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

/// フッターデコレーション
final footerBoxDecoration = BoxDecoration(
    color: Colors.orange,
    border: Border.all(color: Colors.black87, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(7)));

/// 大分類ラベル文字スタイル
const majorLabelStyle = TextStyle(fontSize: 18.0);

/// 小分類ラベル文字スタイル
const minorLabelStyle = TextStyle(fontSize: 12);

/// 基礎点ラベル文字スタイル
const basePointLabelStyle = TextStyle(
  color: Colors.grey,
  fontSize: 28,
  fontWeight: FontWeight.bold,
);

/// カウント文字スタイル
const countLabelStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
);

/// 小分類行の区切り線スタイル
Border typeRowBorderStyle(BuildContext context, int index) {
  Border border;
  final divider = BorderSide(
    width: 0.5,
    color: Theme.of(context).dividerColor,
  );
  if (index != 0) {
    border = Border(
      // index!=0はleftとtopのみ
      left: divider,
      top: divider,
    );
  } else {
    border = Border(
      // index==0はleftのみ
      left: divider,
    );
  }
  return border;
}

/// 大分類項目ラベルの幅
const majorRowWidth = 23.0;

/// 小分類1行の高さ
const minorRowHeight = 50.0;
