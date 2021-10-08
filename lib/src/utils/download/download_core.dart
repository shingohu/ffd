import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'download_options.dart';
import 'downloader.dart';

class DownloaderCore {
  /// StreamSubscription used to link with the download streaming.
  StreamSubscription? _inner;

  /// Inner utils
  final DownloadOptions _options;

  /// Inner url
  final String _url;

  /// Check if the download was cancelled.
  bool _isCancelled = false;

  DownloadStatus get status => _options.status;

  DownloaderCore._(StreamSubscription inner, DownloadOptions options, String url)
      : _inner = inner,
        _options = options,
        _url = url;

  /// Start a new Download progress.
  /// Returns a [DownloaderCore]
  static Future<DownloaderCore?> download(String url, DownloadOptions options) async {
    try {
      // ignore: cancel_subscriptions
      final subscription = await _initDownload(url, options);
      if (subscription != null) {
        return DownloaderCore._(subscription, options, url);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Init a new Download, however this returns a [DownloaderCore]
  /// use at your own risk.
  static Future<StreamSubscription?> _initDownload(String url, DownloadOptions options) async {
    var lastProgress = await options.progressCache.getProgress(url);

    ///不文件存在
    if (!options.tempFile.existsSync()) {
      lastProgress = 0;
      options.progressCache.resetProgress(url);
    } else {
      ///文件存在 但是下载进度为0,删掉重新下载
      if (lastProgress == 0) {
        options.tempFile.deleteSync();
      }
    }
    try {
      final client = options.client ?? Dio(BaseOptions(sendTimeout: 60));
      StreamSubscription? subscription;

      final file = await options.tempFile.create(recursive: true);
      final response = await client.get(
        url,
        options: Options(responseType: ResponseType.stream, headers: {HttpHeaders.rangeHeader: 'bytes=$lastProgress-'}),
      );
      options.status = DownloadStatus.DOWNING;
      final _total = int.tryParse(response.headers.value(HttpHeaders.contentLengthHeader) ?? "0") ?? 0;

      final sink = await file.open(mode: FileMode.writeOnlyAppend);
      subscription = response.data.stream.listen(
        (Uint8List data) async {
          subscription?.pause();
          await sink.writeFrom(data);
          final currentProgress = lastProgress + data.length;
          await options.progressCache.setProgress(url, currentProgress.toInt());
          options.downloadCallback.onProgress(url, current: currentProgress.toInt(), total: _total);
          lastProgress = currentProgress;
          subscription?.resume();
        },
        onDone: () async {
          file.renameSync(options.file.path);
          options.status = DownloadStatus.COMPLETE;
          options.downloadCallback.onDone(url);
          await sink.close();
          if (options.client != null) client.close();
        },
        onError: (error) async {
          options.status = DownloadStatus.PAUSE;
          options.downloadCallback.onError(url);
          subscription?.cancel();
        },
      );
      return subscription;
    } catch (e) {
      options.downloadCallback.onError(url);
      return null;
    }
  }

  /// Pause any current download.
  Future<void> pause() async {
    _isActive();
    await _inner?.cancel();
    _options.status = DownloadStatus.PAUSE;
  }

  /// Resume any current download, with the pending progress.
  Future<void> resume() async {
    _isActive();
    if (_options.status == DownloadStatus.DOWNING) return;
    _inner = await _initDownload(_url, _options);
  }

  /// Cancel any current download, even if the download is [pause]
  Future<void> cancel() async {
    _isActive();
    await _inner?.cancel();
    await _options.progressCache.resetProgress(_url);
    if (_options.deleteOnCancel == true) {
      await _options.file.delete();
    }
    _isCancelled = true;
    _options.status = DownloadStatus.IDLE;
  }

  /// Check if the download was cancelled.
  void _isActive() {
    if (_isCancelled) throw StateError('Already cancelled');
  }
}
