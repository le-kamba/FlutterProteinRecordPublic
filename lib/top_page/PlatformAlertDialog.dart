import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Platform別ダイアログを作るクラス
class PlatformAlertDialog {
  final String title;
  final Widget body;
  final String message;
  final List<Widget> actions;
  final Key key;

  /// [key] DialogにつけるKey
  /// [title] Dialogのタイトル
  /// [body] contentに指定するWidget. [message]とは排他的に指定して下さい。
  /// [message] メッセージ文字列。[body]とは排他的に指定して下さい。
  /// [actions] actions(ボタンウィジェットのリスト)
  PlatformAlertDialog(
      {this.key,
      @required this.title,
      this.body,
      this.message,
      @required this.actions}) {
    if (body == null && message == null) {
      throw ArgumentError.notNull("[message]または[body]のどちらかを必ず指定して下さい。");
    }
  }

  /// プラットフォーム別のダイアログを設定に基づいてビルドする
  Widget build() {
    return Platform.isIOS
        ? new CupertinoAlertDialog(
            key: key,
            title: Text(title),
            content: body != null ? body : Text(message),
            actions: actions)
        : new AlertDialog(
            key: key,
            title: Text(title),
            content: body != null ? body : Text(message),
            actions: actions,
          );
  }
}
