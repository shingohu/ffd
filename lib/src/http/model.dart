class BaseModel {
  int code;
  String msg;
  dynamic data;

  BaseModel(this.code, this.msg, this.data);

  @override
  String toString() {
    return {
      "code": code,
      "msg": msg,
      "data": data,
    }.toString();
  }
}

class HttpResponseName {
  ///返回数据中code的名称
  static String codeName = "code";

  ///返回数据中成功的code的值
  static int successCodeValue = 200;

  ///返回数据中data的名称
  static String dataName = "data";

  ///返回数据中message的名称
  static String messageName = "message";

  static initHttpResponseName({String? codeName, String? dataName, String? messageName, int? successCodeValue}) {
    if (codeName != null) {
      HttpResponseName.codeName = codeName;
    }

    if (dataName != null) {
      HttpResponseName.dataName = dataName;
    }

    if (messageName != null) {
      HttpResponseName.messageName = messageName;
    }

    if (successCodeValue != null) {
      HttpResponseName.successCodeValue = successCodeValue;
    }
  }
}

class HttpResponse {
  bool success = false;
  dynamic data;
  dynamic originData;
  int? code;
  String? msg;

  int? statusCode;
  bool isNetError = false;
  bool isServerError = false;
  bool isRequestError = false;
  bool isCancelError = false;

  HttpResponse.success(dynamic data, {int? statusCode}) {
    this.statusCode = statusCode;
    this.originData = data;
    if (data is Map<String, dynamic>) {
      dynamic _code = data[HttpResponseName.codeName];
      if (_code is String) {
        this.code = int.tryParse(_code);
      } else {
        this.code = _code;
      }
      if (this.code == HttpResponseName.successCodeValue) {
        this.success = true;
        this.data = data[HttpResponseName.dataName];
      } else {
        ///业务不正常
        this.success = false;
      }
      this.msg = data[HttpResponseName.messageName];
    }
  }

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

  bool get isEmpty {
    if (data == null) {
      return true;
    }
    if (data is List) {
      return data.length == 0;
    } else {
      return true;
    }
  }

  T? entity<T>({required T fromJson(data)}) {
    if (data == null) {
      return null;
    }
    return fromJson(data);
  }
}
