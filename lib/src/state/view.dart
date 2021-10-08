import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'state.dart';

typedef RetryCallback = void Function();

class RetryPage extends StatelessWidget {
  final Widget child;
  final RetryCallback? retryCallback;

  RetryPage({Key? key, required this.child, this.retryCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, cons) {
        Widget retryWidget = Container(width: double.infinity, height: double.infinity, child: child);
        if (cons.maxHeight.isInfinite || cons.maxWidth.isInfinite) {
          retryWidget = child;
        }
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            retryCallback?.call();
          },
          child: retryWidget,
        );
      },
    );
  }
}

Widget stateViewBuilder(ViewState viewState,
    {required Widget Function() builder, Widget Function()? idle, Widget Function()? loading, Widget Function()? empty, Widget Function()? error, RetryCallback? retry}) {
  if (viewState == ViewState.loading) {
    return loading?.call() ?? StateViewConfig.instance.loading;
  } else if (viewState == ViewState.empty) {
    return RetryPage(
      child: empty?.call() ?? StateViewConfig.instance.empty,
      retryCallback: retry,
    );
  } else if (viewState == ViewState.error) {
    return RetryPage(
      child: error?.call() ?? StateViewConfig.instance.error,
      retryCallback: retry,
    );
  } else if (viewState == ViewState.data) {
    return builder();
  }
  return idle?.call() ?? Container();
}

class StateViewConfig {
  static final StateViewConfig _instance = StateViewConfig._();

  static StateViewConfig get instance {
    return _instance;
  }

  StateViewConfig._();

  //数据加载中的
  Widget loading = _LoadingPage();

  //页面数据加载失败
  Widget error = Center(
    child: Padding(padding: EdgeInsets.all(20), child: Text("服务器找不到啦～")),
  );

  //页面数据为空
  Widget empty = Center(
    child: Padding(padding: EdgeInsets.all(20), child: Text("暂无数据")),
  );
}

class _LoadingPage extends StatelessWidget {
  _LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(),
    );
  }
}
