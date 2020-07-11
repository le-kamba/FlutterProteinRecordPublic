import 'package:flutter/material.dart';

/// TopPage用のVieModel
/// ChangeNotifierでは都合が悪いのでBLoC
/// 厳密にはBLoCにはビジネスロジックしか含んではいけないので、BLoCではない。
/// ViewModelに近いが、Providerパターンの違いを明確にするため、`Bloc`を使う
class TopPageBloc {
  final PageController _pageController = PageController(
    initialPage: 1,
  );

  get pageController => _pageController;

  int _currentPage = 1;

  TopPageBloc();

  void dispose() {
    _pageController.dispose();
  }

  /// PageViewのスワイプによるページ移動で呼ぶ
  void onPageChanged(int index) {
    _currentPage = index;
  }

  /// PageViewのページ移動
  void onPageMove(int diffIndex) {
    _pageController.animateToPage(_currentPage + diffIndex,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
  }
}
