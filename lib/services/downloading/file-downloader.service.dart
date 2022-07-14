import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FileDownloadService {

  static Future<bool> containsFile(String url) async {
    return await getFile(url) != null;
  }

  static Future<FileInfo?> getFile(String url) async {
    return await DefaultCacheManager().getFileFromCache(url);
  }

  static Stream<FileResponse> cacheFile(String url)  {
    return DefaultCacheManager().getFileStream(url, withProgress: true);
  }

  static removeFile(String url) async {
    await DefaultCacheManager().removeFile(url);
  }

  static clearCache() async {
    await DefaultCacheManager().emptyCache();
  }
}