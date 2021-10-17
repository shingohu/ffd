import 'model.dart';

abstract class Http {
  Future<HttpResponse> get(String path, {dynamic params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert});

  Future<HttpResponse> post(String path, {dynamic params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert});

  Future<HttpResponse> delete(String path, {dynamic params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert});

  Future<HttpResponse> put(String path, {dynamic params, bool showLog = false, HttpResponse Function(HttpResponse response)? convert});
}
