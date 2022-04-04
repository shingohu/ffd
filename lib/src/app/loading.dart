import 'package:ffd/ffd.dart';
import 'package:flutter/material.dart';

class LoadingMixin {
  loadingListen(bool show, {BuildContext? context, bool cancel = false, Widget? loadingWidget}) {
    if (show) {
      LoadingManager.instance.showLoading(context: context, cancel: cancel, loadingWidget: loadingWidget);
    } else {
      LoadingManager.instance.dismissLoading(context: context);
    }
  }

  toastListen(String? msg, {BuildContext? context}) {
    if (msg != null && msg.trim().length != 0) {
      showToast(msg, context: context);
    }
  }
}

class LoadingManager {
  factory LoadingManager() => _getInstance();

  static LoadingManager get instance => _getInstance();
  static LoadingManager? _instance;

  static LoadingManager _getInstance() {
    if (_instance == null) {
      _instance = new LoadingManager._internal();
    }
    return _instance!;
  }

  LoadingManager._internal();

  bool _isLoading = false;
  Route? _route;
  Widget? _loadingWidget;

  showLoading({BuildContext? context, bool cancel = false, Widget? loadingWidget}) {
    if (!_isLoading) {
      if (_route != null && _route!.isActive) {
        return;
      }
      _isLoading = true;
      _route = RawDialogRoute(
          barrierDismissible: cancel,
          barrierColor: Colors.transparent,
          pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
            return WillPopScope(
                child: Stack(alignment: AlignmentDirectional.center, children: [loadingWidget ?? _loadWidget(buildContext)]),
                onWillPop: () async {
                  return cancel;
                });
          });
      if (context == null) {
        NavigatorManager.push(_route!);
      } else {
        Navigator.of(context).push(_route!);
      }
    }
  }

  void dismissLoading({BuildContext? context}) {
    if (_isLoading) {
      _isLoading = false;
      if (_route != null && _route!.isActive) {
        if (context == null && NavigatorManager.mContext != null) {
          if (_route!.isCurrent) {
            Navigator.of(NavigatorManager.mContext!).pop();
          } else {
            NavigatorManager.removeRoute(_route!);
          }
        } else {
          if (_route!.isCurrent) {
            Navigator.of(context!).pop();
          } else {
            Navigator.of(context!).removeRoute(_route!);
          }
        }
      }
    }
  }

  set loadingWidget(Widget loading) {
    this._loadingWidget = loading;
  }

  Widget _loadWidget(BuildContext context) {
    return _loadingWidget ??
        Container(
          color: Colors.white,
          width: 100,
          height: 100,
          child: CupertinoActivityIndicator(),
        );
  }
}
