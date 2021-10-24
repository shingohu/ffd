import 'dart:collection';

import 'package:flutter/material.dart';

class NavigatorManager {
  static final LinkedHashMap<Object, GlobalKey<NavigatorState>> _navigatorKeyMap = LinkedHashMap();

  ///获取当前导航的key
  static GlobalKey<NavigatorState>? get _mNavigatorKey => _navigatorKeyMap.values.length > 0 ? _navigatorKeyMap.values.last : null;

  static NavigatorState? get _mNavigatorState => _mNavigatorKey?.currentState;

  static BuildContext? get mContext => _mNavigatorState?.context;

  ///保存当前的导航key
  static addNavigatorKey(Object subscribe, GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKeyMap[subscribe] = navigatorKey;
  }

  ///移除当前导航的key
  static removeNavigatorKey(Object subscribe) {
    _navigatorKeyMap.remove(subscribe);
  }

  ///生成并注册一个导航的key
  static GlobalKey<NavigatorState> registerNavigatorKey(Object subscribe, {GlobalKey<NavigatorState>? navigatorKey}) {
    removeNavigatorKey(subscribe);
    navigatorKey ??= GlobalKey<NavigatorState>();
    addNavigatorKey(subscribe, navigatorKey);
    return navigatorKey;
  }

  ///反注册一个导航的key
  static void unRegisterNavigatorKey(Object subscribe) {
    removeNavigatorKey(subscribe);
  }

  ///跳转到一个路由
  static Future<T?> push<T extends Object?>(Route<T> route) {
    assert(_mNavigatorState != null, "navigator state must not be null");
    return _mNavigatorState!.push(route);
  }

  ///根据路由名称跳转
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    assert(_mNavigatorState != null, "navigator state must not be null");
    return _mNavigatorState!.pushNamed<T>(routeName, arguments: arguments);
  }

  ///跳转到指定名称路由并且移出不满足条件的路由
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return _mNavigatorState!.pushNamedAndRemoveUntil(newRouteName, predicate);
  }

  
  static void pop<T extends Object?>([ T? result ]){
    _mNavigatorState!.pop(result);
  }

  ///移出路由
  static void removeRoute(Route<dynamic> route) {
    assert(_mNavigatorState != null, "navigator state must not be null");
    _mNavigatorState!.removeRoute(route);
  }
}
