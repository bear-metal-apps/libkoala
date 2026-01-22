import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';

class HiveCacheInterceptor extends Interceptor {
  final Box box;

  HiveCacheInterceptor(this.box);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method != 'GET') {
      return handler.next(options);
    }

    final key = options.uri.toString();
    final forceRefresh = options.extra['forceRefresh'] == true;

    if (forceRefresh) {
      box.delete(key);
    } else {
      final record = box.get(key);
      if (record is Map && record['timestamp'] is int) {
        final timestamp = record['timestamp'] as int;

        if (DateTime.now().millisecondsSinceEpoch - timestamp < 3600000) {
          final cachedData = record['data'];
          final normalized = cachedData is Map
              ? Map<String, dynamic>.from(cachedData)
              : cachedData is List
                  ? List<dynamic>.from(cachedData)
                  : cachedData;

          return handler.resolve(
            Response(
              requestOptions: options,
              data: normalized,
              statusCode: 200,
            ),
          );
        } else {
          box.delete(key);
        }
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      final key = response.requestOptions.uri.toString();
      box.put(key, <String, dynamic>{
        'data': response.data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    handler.next(response);
  }
}
