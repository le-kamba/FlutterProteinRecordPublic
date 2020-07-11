import 'package:flutter/widgets.dart';

/// ライフサイクルコールバックインターフェース
class LifecycleCallback {
  void onResumed() {}

  void onPaused() {}

  void onInactive() {}

  void onDetached() {}
}

/// ライフサイクルを受け取れるStatefulWidget
class LifecycleManager extends StatefulWidget {
  final Widget child;
  final LifecycleCallback callback;

  LifecycleManager({Key key, this.child, this.callback}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    switch (state) {
      case AppLifecycleState.resumed:
        widget.callback?.onResumed();
        break;
      case AppLifecycleState.inactive:
        widget.callback?.onInactive();
        break;
      case AppLifecycleState.paused:
        widget.callback?.onPaused();
        break;
      case AppLifecycleState.detached:
        widget.callback?.onDetached();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
