import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';

import '../injection/injector.dart';
import '../services/user/user.service.dart';

var options = BaseOptions(
  //baseUrl: "http://192.168.10.177:5000/",
  baseUrl: 'https://talkaboat.azurewebsites.net/',
  connectTimeout: 5000,
  receiveTimeout: 15000,
);

var cacheOptions = CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),

  // All subsequent fields are optional.

  // Default.
  policy: CachePolicy.request,
  // Returns a cached response on error but for statuses 401 & 403.
  // Also allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to [null].
  hitCacheOnErrorExcept: [401, 403],
  // Overrides any HTTP directive to delete entry past this duration.
  // Useful only when origin server has no cache config or custom behaviour is desired.
  // Defaults to [null].
  maxStale: const Duration(days: 1),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Overriding [keyBuilder] is strongly recommended when [true].
  allowPostMethod: false,
);

Dio dio = Dio(options);

void configDio() {
  int _activeRequestCount = 0;
  int _requestLimit = 10;
  Timer.periodic(const Duration(seconds: 1), (timer) {
    _activeRequestCount = 0;
    debugPrint("RESET 0");
  });

  dio.interceptors.add(QueuedInterceptorsWrapper(onRequest: (options, handler) async {
    final token = getIt<UserService>().token;
    options.headers['Authorization'] = "Bearer $token";
    _activeRequestCount++;
    if (_activeRequestCount >= _requestLimit) {
      debugPrint("request $_activeRequestCount");
      Future.delayed(Duration(seconds: 1), () {
        return handler.next(options);
      });
    } else {
      return handler.next(options);
    }
    // If you want to resolve the request with some custom data，
    // you can resolve a `Response` object eg: `handler.resolve(response)`.
    // If you want to reject the request with a error message,
    // you can reject a `DioError` object eg: `handler.reject(dioError)`
  }, onResponse: (response, handler) {
    // when response is received
    _activeRequestCount--;
    debugPrint("response $_activeRequestCount");
    // Do something with response data
    return handler.next(response); // continue
    // If you want to reject the request with a error message,
    // you can reject a `DioError` object eg: `handler.reject(dioError)`
  }, onError: (DioError e, handler) {
    if (e.response?.statusCode == 401) {
      getIt<UserService>().logout();
    }
    // Do something with response error
    return handler.next(e); //continue
    // If you want to resolve the request with some custom data，
    // you can resolve a `Response` object eg: `handler.resolve(response)`.
  }));
  dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
}
