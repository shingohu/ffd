import 'package:ffd/ffd.dart';

import 'http.dart';

///这里考虑到多个模块单独配置 不进行单例化操作
///其实项目中其它部分单例化的东西也应该优化下
class HttpUtil implements Http {
  late Http http;

  HttpUtil(this.http);

  @override
  Future<HttpResponse> get(String path, {params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert}) {
    return http.get(path, params: params, showLog: showLog, convert: convert);
  }

  @override
  Future<HttpResponse> post(String path, {params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert}) {
    return http.post(path, params: params, showLog: showLog, convert: convert);
  }

  @override
  Future<HttpResponse> put(String path, {params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert}) {
    return http.put(path, params: params, showLog: showLog, convert: convert);
  }

  @override
  Future<HttpResponse> delete(String path, {params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert}) {
    return http.delete(path, params: params, showLog: showLog, convert: convert);
  }
}
