import 'package:dio/dio.dart';

class CustomLogInterceptor extends Interceptor {
  CustomLogInterceptor({
    this.request = false,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseLog = false,
    this.responseHeader = false,
    this.responseBody = false,
    this.error = true,
    this.logPrint = print,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file, for example:
  ///```dart
  ///  var file=File("./log.txt");
  ///  var sink=file.openWrite();
  ///  dio.interceptors.add(LogInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  ///```
  void Function(Object object) logPrint;

  bool responseLog;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    //options.headers;
    if (request) {
      logPrint('*** Request ***');
      _printKV('uri', options.uri);
      _printKV('method', options.method);
      _printKV('responseType', options.responseType.toString());
      _printKV('followRedirects', options.followRedirects);
      _printKV('connectTimeout', options.connectTimeout);
      _printKV('sendTimeout', options.sendTimeout);
      _printKV('receiveTimeout', options.receiveTimeout);
      _printKV('receiveDataWhenStatusError', options.receiveDataWhenStatusError);
      _printKV('extra', options.extra);
    }

    if (requestHeader) {
      logPrint('request headers:');
      options.headers.forEach((key, v) => _printKV(' $key', v));
    }
    if (requestBody && options.data != null) {
      logPrint('request data:');
      if (options.data is FormData) {
        (options.data as FormData).fields.forEach((element) {
          _printKV(element.key, element.value);
        });

        (options.data as FormData).files.forEach((element) {
          _printKV(element.key, element.value);
        });
      } else {
        _printAll(options.data);
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _printResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (error) {
      logPrint('*** DioError ***:');
      logPrint('uri: ${err.requestOptions.uri}');
      logPrint('$err');
      if (err.response != null) {
        _printResponse(err.response!);
      }
      logPrint('');
    }

    handler.next(err);
  }

  void _printResponse(Response response) {
    if (responseLog) {
      logPrint('*** Response ***');
      _printKV('uri', response.requestOptions.uri);
      if (responseHeader) {
        _printKV('statusCode', response.statusCode ?? 0);
        if (response.isRedirect == true) {
          _printKV('redirect', response.realUri);
        }

        logPrint('headers:');
        response.headers.forEach((key, v) => _printKV(' $key', v.join('\r\n\t')));
      }
      if (responseBody) {
        logPrint('Response Text:');
        _printAll(response.toString());
      }
    }
  }

  void _printKV(String key, Object v) {
    logPrint('$key: $v');
  }

  void _printAll(msg) {
    logPrint(msg);
  }
}
