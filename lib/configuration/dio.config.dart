import 'package:dio/dio.dart';
import 'package:talkaboat/services/user/user.service.dart';

import '../injection/injector.dart';

var options = BaseOptions(
  baseUrl: 'https:/api.talkaboat.online/',
  connectTimeout: 5000,
  receiveTimeout: 3000,
);
Dio dio = Dio(options);

void configDio() {
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    final token = getIt<UserService>().token;
    options.headers['Authorization'] = "Bearer $token";
    print(options.headers["Authorization"]);
    return handler.next(options); //continue
    // If you want to resolve the request with some custom data，
    // you can resolve a `Response` object eg: `handler.resolve(response)`.
    // If you want to reject the request with a error message,
    // you can reject a `DioError` object eg: `handler.reject(dioError)`
  }, onResponse: (response, handler) {
    // Do something with response data
    return handler.next(response); // continue
    // If you want to reject the request with a error message,
    // you can reject a `DioError` object eg: `handler.reject(dioError)`
  }, onError: (DioError e, handler) {
    // Do something with response error
    return handler.next(e); //continue
    // If you want to resolve the request with some custom data，
    // you can resolve a `Response` object eg: `handler.resolve(response)`.
  }));
}
