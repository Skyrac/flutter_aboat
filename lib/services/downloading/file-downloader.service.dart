import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FileDownloadService {
  static Set<String> cachedFiles = {};

  static bool containsFile(String url) {
    return cachedFiles.any((element) => element == url);
  }

  static Future<FileInfo?> getFile(String url) async {
    var file = await DefaultCacheManager().getFileFromCache(url);
    if(file != null) {
      cachedFiles.add(url);
    }
    return file;
  }

  static Stream<FileResponse> cacheFile(String url)  {
    cachedFiles.add(url);
    return DefaultCacheManager().getFileStream(url, withProgress: true);
  }

  static Future<Stream<FileResponse>?> cacheOrDelete(String url) async  {
    if(await DefaultCacheManager().getFileFromCache(url) != null) {
      await removeFile(url);
    } else {
      return cacheFile(url);
    }
    return null;
  }

  static removeFile(String url) async {
    cachedFiles.remove(url);
    await DefaultCacheManager().removeFile(url);
  }

  static clearCache() async {
    cachedFiles.clear();
    await DefaultCacheManager().emptyCache();
  }
}