import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pr;

import 'bezier_indicator.dart';

typedef OnRefresh = Future<dynamic> Function();
typedef OnLoading = Future<dynamic> Function();

class RefreshView extends StatefulWidget {
  final OnRefresh? onRefresh;
  final OnLoading? onLoading;

  final bool hasMore;
  final Widget child;
  final String? noMoreText;
  final Widget? header;

  RefreshView(
      {required this.child,
      this.onRefresh,
      this.onLoading,
      this.hasMore = false,
      this.noMoreText ,
      this.header});

  @override
  _RefreshViewState createState() => _RefreshViewState();
}

class _RefreshViewState extends State<RefreshView> {
  pr.RefreshController _refreshController = pr.RefreshController();

  @override
  void initState() {
    super.initState();
    if (widget.hasMore == false) {
      _refreshController.loadNoData();
    }
  }

  @override
  void didUpdateWidget(covariant RefreshView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasMore == false) {
      _refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return refreshView(
        child: widget.child,
        onRefresh: widget.onRefresh,
        onLoading: widget.onLoading,
        header: widget.header);
  }

  Widget refreshView({
    required Widget child,
    Widget? header,
    OnRefresh? onRefresh,
    OnLoading? onLoading,
  }) {
    return pr.RefreshConfiguration(
      footerTriggerDistance: 500,
      enableBallisticLoad: true,
      headerBuilder: () {
        return header ?? BezierCircleHeader(
          dismissType: BezierDismissType.ScaleToCenter,
        );
      },
      footerBuilder: () {
        return pr.CustomFooter(
          onClick: () {
            if (_refreshController.footerStatus == pr.LoadStatus.failed) {
              _refreshController.requestLoading();
            }
          },
          builder: (ctx, mode) {
            Widget body;
            TextStyle style = TextStyle(color: Color(0xff666666), fontSize: 14);
            if (mode == pr.LoadStatus.idle) {
              body = Text("上拉加载更多", style: style);
            } else if (mode == pr.LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == pr.LoadStatus.failed) {
              body = Text("加载失败,点击重试！", style: style);
            } else if (mode == pr.LoadStatus.canLoading) {
              body = Text("松手,加载更多!", style: style);
            } else {
              body = Text(widget.noMoreText ?? "没有更多啦!", style: style);
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        );
      },
      child: pr.SmartRefresher(
        controller: _refreshController,
        child: child,
        enablePullDown: onRefresh != null,
        enablePullUp: true,
        onRefresh: () async {
          await onRefresh?.call();
          _refreshController.refreshCompleted(resetFooterState: true);
        },
        onLoading: () async {
          bool noSuccess = (await onLoading?.call()) == false;
          if (noSuccess) {
            _refreshController.loadFailed();
          } else {
            _refreshController.loadComplete();
          }
        },
      ),
    );
  }
}







