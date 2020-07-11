/// Material Routeのパス名
class RoutePathName {
  static const String INDEX = '/';
  static const String TUTORIAL = '/tutorial';
  static const String INPUT = '/input';
  static const String INFO = '/info';
  static const String DETAIL = '/detail';
}

/// ページ名
/// Analytics用と、ページ遷移でのtagの両方に使用
class PageName {
  static const String TOP = 'Topページ';
  static const String TUTORIAL = 'Tutorialページ';
  static const String INPUT = 'Inputページ';
  static const String INFO = 'Informationページ';
  static const String DETAIL = 'Detailページ';
}

/// 設定ファイルキー
class PreferenceKey {
  static const String TUTORIAL_DONE = 'tutorialDone';
  static const String POLICY_AGREE_VERSION = 'policy';
  static const String VERSIONS_CHECK_LAST_DATE = 'check_last_dadte';
}

///　AppストアURL
const APP_STORE_URL = 'https://itunes.apple.com/jp/app/id1512588126?mt=8';

/// Playストアurl
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=jp.kasa.les.proteinrecord';

/// プライバシーポリシーページ
const POLICY_URL = "https://flutterproteinrecord.web.app/privacypolicy.html";
