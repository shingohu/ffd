import 'package:ffd/src/http/dio/dio_http.dart';

import 'config.dart';
import 'http.dart';
import 'model.dart';

class HttpUtil implements Http {
  late Http http;

  static HttpUtil? _instance;

  static HttpUtil get instance => _getInstance();

  factory HttpUtil() => _getInstance();

  static HttpUtil _getInstance() {
    if (_instance == null) {
      _instance = HttpUtil._();
    }
    return _instance!;
  }

  HttpUtil._();

  void initHttp({Http? httpImpl, HttpConfig? config}) {
    if (config != null && httpImpl == null) {
      ///默认实现
      this.http = DioHttp(config);
    } else if (httpImpl != null) {
      this.http = httpImpl;
    }
  }

  @override
  Future<HttpResponse> delete(String path, {params, bool showLog = false}) {
    return http.delete(path, params: params, showLog: showLog);
  }

  @override
  Future<HttpResponse> get(String path, {params, bool showLog = false}) {
    return http.get(path, params: params, showLog: showLog);
  }

  @override
  Future<HttpResponse> post(String path, {params, bool showLog = false}) {
    return http.post(path, params: params, showLog: showLog);
  }

  @override
  Future<HttpResponse> put(String path, {params, bool showLog = false}) {
    return http.put(path, params: params, showLog: showLog);
  }
}
