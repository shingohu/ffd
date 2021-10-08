import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'download_core.dart';
import 'download_options.dart';
import 'progress_cache.dart';

enum DownloadStatus {
  IDLE,
  DOWNING,
  PAUSE,
  COMPLETE,
}

abstract class DownloadCallback {
  void onProgress(String url, {int current, int total});

  void onError(String url);

  void onDone(String url);

  void onStatusChange(String url, DownloadStatus status);
}

class Downloader implements DownloadCallback {
  factory Downloader() => _getInstance();
  static Downloader? _downloader;

  static Downloader get singleton => _getInstance();

  static Downloader _getInstance() {
    if (_downloader == null) {
      _downloader = Downloader._internal();
    }
    return _downloader!;
  }

  String? _downloadPath;

  List<DownloadCallback> _downloadCallback = [];

  Map<String, DownloaderCore> _downloaderCoreCache = {};

  void addDownloadCallback(DownloadCallback callback) {
    if (!_downloadCallback.contains(callback)) {
      _downloadCallback.add(callback);
    }
  }

  void removeDownloadCallback(DownloadCallback callback) {
    if (_downloadCallback.contains(callback)) {
      _downloadCallback.remove(callback);
    }
  }

  Downloader._internal() {
    downloadPath();
  }

  ///下载目录路径
  Future<String> downloadPath() async {
    if (_downloadPath == null) {
      Directory dic = (await getTemporaryDirectory());
      if (Platform.isAndroid) {
        List<Directory>? dics = await getExternalCacheDirectories();
        if (dics != null && dics.length > 0) {
          dic = dics[0];
        }
      }

      String filesPath = dic.path + "/files";
      if (!await io.Directory(filesPath).exists()) {
        io.Directory(filesPath).createSync();
      }
      _downloadPath = filesPath;
      return filesPath;
    }
    return _downloadPath!;
  }

  Future<io.File?> getCacheFile(String fileName) async {
    File file = File((await downloadPath()) + "/" + fileName);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  Future<io.File> createCacheFile(String fileName) async {
    String path = await downloadPath();
    return io.File(path + "/" + fileName);
  }

  Future<DownloaderCore?> download(String url, String fileName, {DownloadCallback? callback}) async {
    if (callback != null) {
      addDownloadCallback(callback);
    }
    File file = File((await downloadPath()) + "/" + fileName);

    DownloaderCore? core;
    if (_downloaderCoreCache.containsKey(url)) {
      core = _downloaderCoreCache[url]!;
    } else {
      DownloadOptions options = DownloadOptions(url: url, file: file, progressCache: MemoryProgressCache(), downloadCallback: this);

      core = await DownloaderCore.download(url, options);
      if (core != null) {
        _downloaderCoreCache[url] = core;
      }
    }
    return core;
  }

  void pause(String url) {
    if (_downloaderCoreCache.containsKey(url)) {
      _downloaderCoreCache[url]?.pause();
    }
  }

  void resume(String url) {
    if (_downloaderCoreCache.containsKey(url)) {
      _downloaderCoreCache[url]?.resume();
    }
  }

  void cancel(String url) {
    if (_downloaderCoreCache.containsKey(url)) {
      _downloaderCoreCache.remove(url);
      _downloaderCoreCache[url]?.cancel();
    }
  }

  DownloadStatus status(String url) {
    if (_downloaderCoreCache.containsKey(url)) {
      return _downloaderCoreCache[url]?.status ?? DownloadStatus.IDLE;
    }
    return DownloadStatus.IDLE;
  }

  @override
  void onDone(String url) {
    _downloaderCoreCache.remove(url);
    _downloadCallback.forEach((element) {
      element.onDone(url);
    });
  }

  @override
  void onError(String url) {
    _downloadCallback.forEach((element) {
      element.onError(url);
    });
  }

  @override
  void onProgress(String url, {int? current, int? total}) {
    _downloadCallback.forEach((element) {
      element.onProgress(url, current: current ?? 0, total: total ?? -1);
    });
  }

  @override
  void onStatusChange(String url, DownloadStatus status) {
    _downloadCallback.forEach((element) {
      element.onStatusChange(url, status);
    });
  }
}
