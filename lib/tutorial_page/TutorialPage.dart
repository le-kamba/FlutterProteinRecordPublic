import 'package:flutter/material.dart';
import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../main.dart';
import '../services/NavigationService.dart';

final Color tutorialBackgroundColor = Color.fromARGB(255, 151, 212, 217);

/// TutorialPage
class TutorialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<double> notifier = ValueNotifier(0);
    int pageCount = 4;

    return Scaffold(
      backgroundColor: tutorialBackgroundColor,
      body: WillPopScope(
        onWillPop: () async => false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: SlidingTutorial(
                pageCount: pageCount,
                notifier: notifier,
              ),
            ),
            Container(
              width: double.infinity,
              height: 40,
              color: Colors.white,
              child: SlidingIndicator(
                indicatorCount: pageCount,
                notifier: notifier,
                activeIndicator: Image.asset(
                  'assets/tutorial/dot1.png',
                ),
                inActiveIndicator: Image.asset(
                  'assets/tutorial/dot2.png',
                ),
                margin: 8,
                sizeIndicator: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pager(メインのView Pager部分)
class SlidingTutorial extends StatefulWidget {
  final ValueNotifier<double> notifier;
  final int pageCount;

  SlidingTutorial({Key key, this.notifier, this.pageCount}) : super(key: key);

  @override
  State<SlidingTutorial> createState() => _TutorialState();
}

class _TutorialState extends State<SlidingTutorial> {
  final _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    _pageController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: List<Widget>.generate(
        widget.pageCount,
        (index) => _getPageByIndex(index),
      ),
    );
  }

  Widget _getPageByIndex(int index) {
    final imageName = "assets/tutorial/tutorial${index + 1}.png";
    if (index < 3) {
      return Image.asset(
        imageName,
        alignment: Alignment.center,
        fit: BoxFit.contain,
      );
    } else {
      return GestureDetector(
        onTap: () {
          _onFinishTutorial();
        }, // handle your image tap here
        child: Image.asset(
          imageName,
          key: Key("tutorialLastPage"),
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      );
    }
  }

  void _onScroll() {
    widget.notifier?.value = _pageController.page;
  }

  void _onFinishTutorial() async {
    // 設定を変更する
    final preference = await SharedPreferences.getInstance();
    preference.setBool(PreferenceKey.TUTORIAL_DONE, true);
    // Topまで戻る
    final navigatorService = locator<NavigationService>();
    navigatorService.goBackTo(ModalRoute.withName(PageName.TOP));
  }
}
