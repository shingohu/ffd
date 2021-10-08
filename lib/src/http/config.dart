import 'model.dart';

///http请求配置
class HttpConfig {
  final int? connectTimeout;
  final int? receiveTimeout;
  final String baseUrl;
  final OnHttpHeaderCallback? onHttpHeaderCallback;
  final OnHttpResponseInterceptor? onHttpResponseInterceptor;
  final OnParseHttpResponseCallback? onParseHttpResponseCallback;

  HttpConfig({required this.baseUrl, this.onParseHttpResponseCallback, this.connectTimeout, this.receiveTimeout, this.onHttpHeaderCallback, this.onHttpResponseInterceptor});
}

///用于获取请求headers
typedef OnHttpHeaderCallback = Map<String, dynamic>? Function();

///用户数据拦截
typedef OnHttpResponseInterceptor = bool Function(int? statusCode, dynamic data);
typedef OnParseHttpResponseCallback = HttpResponse Function(int? statusCode, dynamic data);
