import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/utils/hive_cache_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
HoneycombClient honeycombClient(Ref ref) {
  return HoneycombClient(ref);
}

class HoneycombClient {
  final Ref _ref;

  HoneycombClient(this._ref);

  Future<T> _performRequest<T>(
      String method,
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool forceRefresh = false,
      }) async {
    final dio = _ref.read(dioProvider);
    final authService = _ref.read(authProvider);

    String? token;
    bool isOffline = false;

    try {
      token = await authService.getAccessToken([
        'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7',
      ]);
    } on OfflineAuthException {
      isOffline = true;
    } catch (e) {
      rethrow;
    }

    try {
      final response = await dio.request(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          extra: {'forceRefresh': forceRefresh, 'isOffline': isOffline},
        ),
      );

      return response.data as T;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'API Error: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      }
      throw Exception('Network Error: ${e.message}');
    }
  }

  Future<T> get<T>(
      String endpoint, {
        bool forceRefresh = false,
        Map<String, dynamic>? queryParams,
      }) async {
    return _performRequest<T>(
      'GET',
      endpoint,
      forceRefresh: forceRefresh,
      queryParameters: queryParams,
    );
  }

  Future<T> post<T>(
      String endpoint, {
        required dynamic data,
      }) async {
    return _performRequest<T>('POST', endpoint, data: data);
  }

  Future<T> put<T>(
      String endpoint, {
        required dynamic data,
      }) async {
    return _performRequest<T>('PUT', endpoint, data: data);
  }

  Future<T> patch<T>(
      String endpoint, {
        required dynamic data,
      }) async {
    return _performRequest<T>('PATCH', endpoint, data: data);
  }

  Future<void> delete(String endpoint, {dynamic data}) async {
    return _performRequest<void>('DELETE', endpoint, data: data);
  }
}

// keep these uncs for backwards compat
@Deprecated('Use get<Map<String, dynamic>>() in honeycombClientProvider.')
@riverpod
Future<Map<String, dynamic>> getData(
    Ref ref, {
      required String endpoint,
      bool forceRefresh = false,
    }) async {
  return ref.watch(honeycombClientProvider).get<Map<String, dynamic>>(
    endpoint,
    forceRefresh: forceRefresh,
  );
}

@Deprecated('Use get<List<dynamic>>() in honeycombClientProvider.')
@riverpod
Future<List<dynamic>> getListData(
    Ref ref, {
      required String endpoint,
      bool forceRefresh = false,
    }) async {
  return ref.watch(honeycombClientProvider).get<List<dynamic>>(
    endpoint,
    forceRefresh: forceRefresh,
  );
}