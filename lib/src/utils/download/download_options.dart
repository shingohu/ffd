import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'downloader.dart';
import 'progress_cache.dart';

class DownloadOptions {
  final ProgressCache progressCache;

  /// Dio Client for HTTP Request
  final Dio? client;

  /// Setup a location to store the downloaded file
  final File file;

  ///文件下载地址
  final String url;

  /// should delete when cancel?
  final bool? deleteOnCancel;

  DownloadStatus _status = DownloadStatus.IDLE;

  set status(DownloadStatus status) {
    _status = status;
    downloadCallback?.onStatusChange(url, status);
  }

  DownloadStatus get status {
    return _status;
  }

  File? _tempFile;

  ///临时文件
  File get tempFile {
    if (_tempFile != null) {
      return _tempFile!;
    }
    _tempFile = createTempPath();
    return _tempFile!;
  }

  final DownloadCallback downloadCallback;

  ///创建一个临时文件
  File createTempPath() {
    String fileName = url2md5(url);
    return File(file.parent.path + "/" + fileName);
  }

  DownloadOptions({
    required this.url,
    required this.file,
    required this.progressCache,
    required this.downloadCallback,
    this.client,
    this.deleteOnCancel = false,
  });

  // md5 加密
  String url2md5(String url) {
    var content = new Utf8Encoder().convert(url);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }
}
