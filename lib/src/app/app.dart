import 'dart:developer';

import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
ffdPrint(dynamic msg, {String? tag}) {
  if (!kReleaseMode) {
    log("${tag ?? "FFD"} ==> $msg", name: tag ?? "");
  }
}

class App {
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    ///初始化SP缓存
    await SpUtil.getInstance();
  }
}
