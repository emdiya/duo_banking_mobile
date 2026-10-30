import 'package:dio/dio.dart';

/// Future API transport. Mock banking never uses a network connection.
class ApiClient {
  ApiClient({required String baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
  final Dio dio;
  void dispose() => dio.close();
}
