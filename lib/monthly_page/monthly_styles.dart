import 'package:flutter/material.dart';

/// 前後の月の日付ラベル用のテキストスタイル
final otherMonthTextStyle = TextStyle(
  fontSize: 12.0,
  color: Colors.grey[500],
);

/// 前後の月のセル背景色
final otherMonthBackground = BoxDecoration(
    border: Border.all(color: Colors.grey, width: 0.3), color: Colors.black12);

/// 当月の日付ラベル用のテキストスタイル
final todayMonthTextStyle = TextStyle(
  fontSize: 12.0,
  color: Colors.black54,
);

/// 今日のセル背景色
final todayBackground = BoxDecoration(
    border: Border.all(color: Colors.black, width: 0.3),
    color: Colors.purple[50]);

/// 当月のセル背景色
final todayMonthBackground = BoxDecoration(
    border: Border.all(color: Colors.grey, width: 0.3), color: Colors.white70);

/// 0.0点の時の文字スタイル
final zeroPointTextStyle = TextStyle(
  fontWeight: FontWeight.normal,
);

/// 合計点数文字スタイル
final pointTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
);
