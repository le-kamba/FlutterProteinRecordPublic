import 'package:flutter/material.dart';

/// Navigator遷移を管理するサービスクラス
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  /// 指定のパスに遷移
  Future<dynamic> navigateTo(String routeName, {Object args}) async {
    return navigatorKey.currentState.pushNamed(routeName, arguments: args);
  }

  /// 1つ戻る
  /// [result] 前の画面に戻したい結果値
  bool goBack<T extends Object>([T result]) {
    return navigatorKey.currentState.pop(result);
  }

  /// 指定の画面名まで戻る
  /// [predicate] 画面名(not path)
  void goBackTo(RoutePredicate predicate) {
    navigatorKey.currentState.popUntil(predicate);
  }
}
