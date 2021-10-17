class HttpResponse {
  bool success = false;

  /// Response body. may have been transformed, please refer to [ResponseType].
  dynamic body;

  /// Http status code.
  int? statusCode;

  /// Returns the reason phrase associated with the status code.
  /// The reason phrase must be set before the body is written
  /// to. Setting the reason phrase after writing to the body.
  String? statusMessage;

  ///请求路径
  String? path;

  String msg = "";
  bool isNetError = false;
  bool isServerError = false;
  bool isRequestError = false;
  bool isCancelError = false;

  HttpResponse.success({this.body, this.statusCode, this.statusMessage, this.path, this.success = true});

  ///网络异常
  HttpResponse.netError() {
    this.success = false;
    this.msg = "网络异常,请稍后重试";
    this.isNetError = true;
  }

  ///服务器异常
  HttpResponse.serverError() {
    this.success = false;
    this.msg = "服务器异常,请稍后重试";
    this.isServerError = true;
  }

  ///可能参数出错
  HttpResponse.requestError() {
    this.isRequestError = true;
    this.success = false;
    this.msg = "请求异常,请稍后重试";
  }

  ///已取消
  HttpResponse.cancelError() {
    this.isCancelError = true;
    this.success = false;
  }

  HttpResponse.error(String msg) {
    this.success = false;
    this.msg = msg;
  }


}
