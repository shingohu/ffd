import 'model.dart';

abstract class Http {
  Future<HttpResponse> get(String path, {dynamic params, bool showLog = false});

  Future<HttpResponse> post(String path, {dynamic params, bool showLog = false});

  Future<HttpResponse> delete(String path, {dynamic params, bool showLog = false});

  Future<HttpResponse> put(String path, {dynamic params, bool showLog = false});
}
