/// Class used to set/get the progress of the download
abstract class ProgressCache {
  /// Retrieve the progress of the download from a specific `url`
  Future<int> getProgress(String url);

  /// Set the progress of the download from a specific `url`
  Future<void> setProgress(String url, int received);

  /// Remove any progress.
  Future<void> resetProgress(String url) async {
    await setProgress(url, 0);
  }
}

///下载进度缓存,内存有效
class MemoryProgressCache extends ProgressCache {
  factory MemoryProgressCache() => _getInstance();
  static MemoryProgressCache? _cache;

  static MemoryProgressCache get singleton => _getInstance();

  static MemoryProgressCache _getInstance() {
    if (_cache == null) {
      _cache = MemoryProgressCache._();
    }
    return _cache!;
  }

  MemoryProgressCache._();

  ///Inner variable used to access the url attribute.
  final Map<String, int> _inner = {};

  /// Retrieve the progress of the download from a specific `url`
  /// if null then returns 0.

  Future<int> getProgress(String url) async {
    return _inner[url] ?? 0;
  }

  /// Set the progress of the download from a specific `url`
  Future<void> setProgress(String url, int received) async {
    _inner[url] = received;
  }
}
