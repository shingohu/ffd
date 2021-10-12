import 'package:flutter/widgets.dart';
/**
 * 生命周期的回调
 * Page级别:onPageCreate page创建  onPageDispose() page销毁
 */

/// Register the RouteObserver as a navigation observer.
/// MaterialApp 中添加此路由监听

final RouteObserver<ModalRoute<void>> ffdRouteObserver = RouteObserver<ModalRoute<void>>();

abstract class IPageLifecycle {
  static const bool _printLog = false;

  //页面级别的
  void onDispose(BuildContext context) {
    if (_printLog) print("$this ${this.hashCode} 销毁");
  }

  //页面级别的
  void onCreate(BuildContext context) {
    if (_printLog) print("$this  ${this.hashCode} 创建");
  }

  void onResume(BuildContext context) {
    if (_printLog) print("$this ${this.hashCode} 可见");
  }

  void onPause(BuildContext context) {
    if (_printLog) print("$this ${this.hashCode} 不可见");
  }
}

mixin PageLifecycleMixin<T extends StatefulWidget> on State<T> implements RouteAware, IPageLifecycle {
  _AppLifecycleWidgetsBindingObserver? _lifecycleObserver;
  bool _printLog = false;

  //是否在栈顶
  bool _isTop = false;

  bool routeAware = true;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = _AppLifecycleWidgetsBindingObserver(_lifecycleStateCallback);
    WidgetsBinding.instance?.addObserver(_lifecycleObserver!);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      onCreate(context);
      onResume(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (routeAware) {
      ffdRouteObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void dispose() {
    if (routeAware) {
      ffdRouteObserver.unsubscribe(this);
    }
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance?.removeObserver(_lifecycleObserver!);
    }
    _lifecycleObserver = null;
    onDispose(context);
    super.dispose();
  }

  _lifecycleStateCallback(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isTop) {
        onPause(context);
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (_isTop) {
        onResume(context);
      }
    }
  }

  @override
  void didPop() {
    //弹出
    _isTop = false;
  }

  @override
  void didPopNext() {
    //上一个弹出
    onResume(context);
    _isTop = true;
  }

  @override
  void didPush() {
    //入栈
    _isTop = true;
  }

  @override
  void didPushNext() {
    //跳转到下一个
    onPause(context);
    _isTop = false;
  }

  //页面级别的
  void onDispose(BuildContext context) {
    if (_printLog) print("$this destory");
  }

  //页面级别的
  void onCreate(BuildContext context) {
    if (_printLog) print("$this create");
  }

  void onResume(BuildContext context) {
    if (_printLog) print("$this resume");
  }

  void onPause(BuildContext context) {
    if (_printLog) print("$this pause");
  }
}

///app生命周期
mixin AppLifecycleMixin<T extends StatefulWidget> on State<T> {
  _AppLifecycleWidgetsBindingObserver? _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = _AppLifecycleWidgetsBindingObserver(_lifecycleStateCallback);
    WidgetsBinding.instance?.addObserver(_lifecycleObserver!);
  }

  _lifecycleStateCallback(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      onBackground();
    }

    if (state == AppLifecycleState.resumed) {
      onForeground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(_lifecycleObserver!);
    _lifecycleObserver = null;
    super.dispose();
  }

  //应用级别的
  void onBackground() {
    print("App onBackground");
  }

  //应用级别的
  void onForeground() {
    print("App onForeground");
  }
}

class _AppLifecycleWidgetsBindingObserver extends WidgetsBindingObserver {
  final Function(AppLifecycleState) lifecycleStateCallback;

  _AppLifecycleWidgetsBindingObserver(this.lifecycleStateCallback);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    lifecycleStateCallback(state);
  }
}

class PageLifecycleWidget extends StatefulWidget {
  final Widget child;
  final Function(BuildContext context)? onCreate;
  final Function(BuildContext context)? onResume;
  final Function(BuildContext context)? onPause;
  final Function(BuildContext context)? onDispose;

  PageLifecycleWidget({Key? key, required this.child, this.onCreate, this.onResume, this.onPause, this.onDispose}) : super(key: key);

  @override
  _PageLifecycleWidgetState createState() => _PageLifecycleWidgetState();
}

class _PageLifecycleWidgetState extends State<PageLifecycleWidget> with PageLifecycleMixin {
  @override
  void onCreate(BuildContext context) {
    if (widget.onCreate != null) {
      widget.onCreate!(context);
    }
  }

  @override
  void didUpdateWidget(PageLifecycleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void onDispose(BuildContext context) {
    if (widget.onDispose != null) {
      widget.onDispose!(context);
    }
  }

  @override
  void onPause(BuildContext context) {
    if (widget.onPause != null) {
      widget.onPause!(context);
    }
  }

  @override
  void onResume(BuildContext context) {
    if (widget.onResume != null) {
      widget.onResume!(context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
