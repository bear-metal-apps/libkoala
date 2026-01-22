import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:libkoala/utils/hive_cache_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:libkoala/libkoala.dart';

part 'api_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl:
          'https://honeycomb-a3d3bbaacjhsaxbu.westus2-01.azurewebsites.net/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final Box<dynamic> cacheBox = Hive.box('api_cache');

  dio.interceptors.add(HiveCacheInterceptor(cacheBox));
  return dio;
}

@riverpod
Future<Map<String, dynamic>> getData(
  Ref ref, {
  required String endpoint,
  bool forceRefresh = false,
}) async {
  final dio = ref.watch(dioProvider);

  final authService = ref.watch(authProvider);
  final String token = await authService.getAccessToken([
    'api://bearmet.al/honeycomb/access',
  ]);

  try {
    final response = await dio.get(
      endpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        extra: {'forceRefresh': forceRefresh},
      ),
    );

    return response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(
        'API Error: ${e.response?.statusCode} - ${e.response?.statusMessage}',
      );
    } else {
      throw Exception('Network Error: ${e.message}');
    }
  }
}

@riverpod
Future<List<dynamic>> getListData(
  Ref ref, {
  required String endpoint,
  bool forceRefresh = false,
}) async {
  final dio = ref.watch(dioProvider);

  final authService = ref.watch(authProvider);
  final String token = await authService.getAccessToken([
    'api://bearmet.al/honeycomb/access',
  ]);

  try {
    final response = await dio.get(
      endpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        extra: {'forceRefresh': forceRefresh},
      ),
    );

    return response.data as List<dynamic>;
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(
        'API Error: ${e.response?.statusCode} - ${e.response?.statusMessage}',
      );
    } else {
      throw Exception('Network Error: ${e.message}');
    }
  }
}
