import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 情報ページ向けスタイル定義
///

/// 区切り線
const listDividerDecoration = BoxDecoration(
  border: Border(
    bottom: BorderSide(
      color: Colors.black12,
      width: 1.0,
    ),
  ),
);

/// アプリ名テキストスタイル
const appNameStyle = TextStyle(fontSize: 28);

/// バージョン番号テキストスタイル
const versionStyle = TextStyle(fontSize: 20);

/// ボタンラベルスタイル
const listLabelsStyle = TextStyle(fontSize: 22);
