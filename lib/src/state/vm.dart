import 'package:flutter/material.dart';

import 'state.dart';

typedef LoadingListener = void Function(bool show);
typedef ToastListener = void Function(String msg);

class Validation {
  bool pass = false;
  dynamic tip;

  Validation.pass() {
    pass = true;
  }

  Validation.unPass(this.tip) {
    pass = false;
  }
}

class ViewModel extends ChangeNotifier {
  /// 防止页面销毁后,异步任务才完成,导致报错
  bool _disposed = false;

  //是否显示loading
  ChangeNotifier? _showLoadingNotifier;

  //显示toast
  ChangeNotifier? _showToastNotifier;

  String _toast = "";
  bool _showLoading = false;

  set loadingListen(LoadingListener? loadingListen) {
    if (loadingListen != null && _showLoadingNotifier == null) {
      _showLoadingNotifier = ChangeNotifier();
      _showLoadingNotifier?.addListener(() {
        loadingListen(_showLoading);
      });
    }
  }

  set toastListen(ToastListener? toastListen) {
    if (toastListen != null && _showToastNotifier == null) {
      _showToastNotifier = ChangeNotifier();
      _showToastNotifier?.addListener(() {
        toastListen(_toast);
      });
    }
  }

  ViewModel({LoadingListener? loadingListen, ToastListener? toastListen}) {
    this.loadingListen = loadingListen;
    this.toastListen = toastListen;
  }

  set showLoading(bool showLoading) {
    if (!_disposed) {
      _showLoading = showLoading;
      if (_showLoadingNotifier?.hasListeners == true) {
        _showLoadingNotifier?.notifyListeners();
      } else {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          _showLoadingNotifier?.notifyListeners();
        });
      }
    }
  }

  set showToast(String toast) {
    if (!_disposed) {
      _toast = toast;
      if (_showToastNotifier?.hasListeners == true) {
        _showToastNotifier?.notifyListeners();
      } else {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          _showToastNotifier?.notifyListeners();
        });
      }
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed && hasListeners == true) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  String toString() {
    return "${hashCode.toString()}";
  }

  void update() {
    notifyListeners();
  }

  bool isEmpty(dynamic data) {
    if (data == null) {
      return true;
    }
    if (data is String) {
      if (data == "" || data.length == 0) {
        return true;
      }
    }
    if (data is List) {
      if (data.length == 0) {
        return true;
      }
    }

    return false;
  }
}

class DataViewModel extends ViewModel {
  ///默认pageSize = 10
  int pageSize = 10;

  ///默认初始page页为1
  int page = 1;

  ViewState _viewState = ViewState.idle;

  bool get loading => _viewState == ViewState.loading;

  bool get idle => _viewState == ViewState.idle;

  bool get empty => _viewState == ViewState.empty;

  bool get error => _viewState == ViewState.error;

  bool get data => _viewState == ViewState.data;

  ViewState get viewState => _viewState;

  set viewState(ViewState viewState) {
    _viewState = viewState;
    update();
  }

  DataViewModel({LoadingListener? loadingListen, ToastListener? toastListen}) : super(loadingListen: loadingListen, toastListen: toastListen);
}
