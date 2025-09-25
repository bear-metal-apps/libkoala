// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Example of using sqflite with Riverpod for generic data caching
/// This demonstrates the integration in a simple way

@ProviderFor(DataCache)
const dataCacheProvider = DataCacheProvider._();

/// Example of using sqflite with Riverpod for generic data caching
/// This demonstrates the integration in a simple way
final class DataCacheProvider
    extends $AsyncNotifierProvider<DataCache, Map<String, dynamic>> {
  /// Example of using sqflite with Riverpod for generic data caching
  /// This demonstrates the integration in a simple way
  const DataCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataCacheProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataCacheHash();

  @$internal
  @override
  DataCache create() => DataCache();
}

String _$dataCacheHash() => r'e00099a57399cae6f1c9db0f23f1f69f8314bc77';

/// Example of using sqflite with Riverpod for generic data caching
/// This demonstrates the integration in a simple way

abstract class _$DataCache extends $AsyncNotifier<Map<String, dynamic>> {
  FutureOr<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, dynamic>>,
                Map<String, dynamic>
              >,
              AsyncValue<Map<String, dynamic>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
