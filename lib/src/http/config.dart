import 'model.dart';

///http请求配置
class HttpConfig {
  final int? connectTimeout;
  final int? receiveTimeout;
  final String baseUrl;
  final HttpHeaderCallback? httpHeaderCallback;
  final HttpResponseInterceptor? httpResponseInterceptor;
  final HttpResponseConvert? httpResponseConvert;

  HttpConfig({required this.baseUrl, this.httpResponseConvert, this.connectTimeout, this.receiveTimeout, this.httpHeaderCallback, this.httpResponseInterceptor});
}

///用于获取请求headers
typedef HttpHeaderCallback = Map<String, dynamic>? Function();

///全部数据数据拦截
typedef HttpResponseInterceptor = bool Function(int? statusCode, dynamic data, {String? path});

///返回数据转换
typedef HttpResponseConvert = T Function<T extends HttpResponse>(HttpResponse response);
