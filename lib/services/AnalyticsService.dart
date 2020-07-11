import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';

/// アナリティクスイベント
enum AnalyticsEvent {
  Agreement,
  CalendarDayTap,
  Button,
  Clear,
}

/// アナリティクス
class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  /// 有効化
  void setAnalyticsEnable() {
    analytics.setAnalyticsCollectionEnabled(true);
  }

  /// 画面名送信
  Future<void> sendScreenName(
      {@required String screenName, String className}) async {
    analytics.setCurrentScreen(
        screenName: screenName, screenClassOverride: className);
  }

  /// カレンダー日付タップイベント送信
  Future<void> sendCalendarEvent() async {
    sendEvent(event: AnalyticsEvent.CalendarDayTap, parameterMap: {});
  }

  /// ボタンタップイベント送信
  Future<void> sendButtonEvent({@required String buttonName}) async {
    sendEvent(
        event: AnalyticsEvent.Button,
        parameterMap: {'buttonName': "$buttonName"});
  }

  /// 削除実施イベント送信
  Future<void> sendClearEvent() async {
    sendEvent(event: AnalyticsEvent.Clear, parameterMap: {});
  }

  /// 規約同意イベント送信
  Future<void> sendAgreementEvent() async {
    sendEvent(event: AnalyticsEvent.Agreement, parameterMap: {});
  }

  /// イベントを送信する
  /// [event] AnalyticsEvent
  /// [parameterMap] パラメータMap
  Future<void> sendEvent(
      {@required AnalyticsEvent event,
      Map<String, dynamic> parameterMap}) async {
    final eventName = event.toString().split('.')[1];
    analytics.logEvent(name: eventName, parameters: parameterMap);
  }
}
