import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/cached_user_info_provider.dart';

void main() {
  group('Cached User Info Provider', () {
    test('cachedUserInfoProvider exists and is accessible', () {
      final container = ProviderContainer();
      
      // Just test that the provider exists and can be created
      expect(cachedUserInfoProvider, isNotNull);
      expect(clearUserInfoCacheProvider, isNotNull);
      
      container.dispose();
    });
  });
}