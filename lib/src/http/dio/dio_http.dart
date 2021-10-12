import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import '../http.dart';
import '../model.dart';
import 'dio_log.dart';

class DioHttp extends Http {
  late Dio _dio;

  ///日志拦截
  late Interceptor _logInterceptor;

  ///用于解析数据回调
  OnParseHttpResponseCallback? _onParseHttpResponseCallback;

  DioHttp(HttpConfig config) {
    _initDio(config);
  }

  void _initDio(HttpConfig config) {
    final options = BaseOptions();
    options.connectTimeout = config.connectTimeout ?? 60000;
    options.receiveTimeout = config.receiveTimeout ?? 60000;

    options.baseUrl = config.baseUrl;

    options.headers.addAll({"character": "UTF-8"});
    options.responseType = ResponseType.json;
    _dio = Dio(options);
    _dio.transformer = _FlutterTransformer();

    ///不需要验证http证书
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) {
        return true;
      };
      return client;
    };
    _dio.interceptors
      ..add(InterceptorsWrapper(onRequest: (options, handler) {
        if (config.onHttpHeaderCallback != null) {
          Map<String, dynamic> headers = config.onHttpHeaderCallback!() ?? {};
          options.headers.addAll(headers);
        }
        return handler.next(options);
      }, onResponse: (response, handler) {
        if (config.onHttpResponseInterceptor != null) {
          ///是否拦截
          bool pass = config.onHttpResponseInterceptor!(response.statusCode, response.data);
          if (pass) {
            return handler.resolve(response);
          }
        }
        return handler.next(response);
      }));

    _logInterceptor = CustomLogInterceptor(logPrint: _ffdPrint, responseBody: true);

    _onParseHttpResponseCallback = config.onParseHttpResponseCallback;
  }

  _ffdPrint(dynamic msg) {
    if (!kReleaseMode) {
      log("${"HTTP"} ==> $msg", name: "HTTP");
    }
  }

  @override
  Future<HttpResponse> delete(String path, {params, bool showLog = false}) async {
    try {
      showLogInterceptor(showLog);
      final response = await _dio.delete<Map<String, dynamic>>(path, queryParameters: params);
      if (_onParseHttpResponseCallback != null) {
        return _onParseHttpResponseCallback!(response.statusCode, response.data);
      }
      return HttpResponse.success(response.data, statusCode: response.statusCode);
    } catch (e) {
      return _handlerError(e);
    }
  }

  @override
  Future<HttpResponse> get(String path, {params, bool showLog = false}) async {
    try {
      showLogInterceptor(showLog);
      Response response;
      if (params != null && params is String) {
        ///restful
        if (!path.endsWith("/")) {
          path = path + "/";
        }
        path = path + params;
        response = await _dio.get<Map<String, dynamic>>(path);
      } else {
        response = await _dio.get<Map<String, dynamic>>(path, queryParameters: params);
      }
      if (_onParseHttpResponseCallback != null) {
        return _onParseHttpResponseCallback!(response.statusCode, response.data);
      }
      return HttpResponse.success(response.data, statusCode: response.statusCode);
    } catch (e) {
      return _handlerError(e);
    }
  }

  @override
  Future<HttpResponse> post(String path, {params, bool showLog = false}) async {
    try {
      showLogInterceptor(showLog);
      final response = await _dio.post<Map<String, dynamic>>(path, data: params);
      if (_onParseHttpResponseCallback != null) {
        return _onParseHttpResponseCallback!(response.statusCode, response.data);
      }
      return HttpResponse.success(response.data, statusCode: response.statusCode);
    } catch (e) {
      return _handlerError(e);
    }
  }

  @override
  Future<HttpResponse> put(String path, {params, bool showLog = false}) async {
    try {
      showLogInterceptor(showLog);
      final response = await _dio.put<Map<String, dynamic>>(path, queryParameters: params);
      if (_onParseHttpResponseCallback != null) {
        return _onParseHttpResponseCallback!(response.statusCode, response.data);
      }
      return HttpResponse.success(response.data, statusCode: response.statusCode);
    } catch (e) {
      return _handlerError(e);
    }
  }

  HttpResponse _handlerError(e) {
    late HttpResponse response;
    if (e is DioError) {
      if (!CancelToken.isCancel(e)) {
        bool netError = e.error is SocketException;
        response = netError ? HttpResponse.netError() : HttpResponse.serverError();
      } else {
        response = HttpResponse.cancelError();
      }
      if (e.response != null) {
        response.statusCode = e.response!.statusCode;
      }
    } else {
      response = HttpResponse.cancelError();
    }
    return response;
  }

  void showLogInterceptor(bool showLog) {
    if (showLog) {
      if (!_dio.interceptors.contains(_logInterceptor)) {
        _dio.interceptors.add(_logInterceptor);
      }
    } else {
      if (_dio.interceptors.contains(_logInterceptor)) {
        _dio.interceptors.remove(_logInterceptor);
      }
    }
  }
}

class _FlutterTransformer extends DefaultTransformer {
  _FlutterTransformer() : super(jsonDecodeCallback: _parseJson);
}

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

_parseJson(String text) {
  return compute(_parseAndDecode, text);
}
