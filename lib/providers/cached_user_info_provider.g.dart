// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_user_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cachedUserInfo)
const cachedUserInfoProvider = CachedUserInfoProvider._();

final class CachedUserInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserInfo?>,
          UserInfo?,
          FutureOr<UserInfo?>
        >
    with $FutureModifier<UserInfo?>, $FutureProvider<UserInfo?> {
  const CachedUserInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedUserInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedUserInfoHash();

  @$internal
  @override
  $FutureProviderElement<UserInfo?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserInfo?> create(Ref ref) {
    return cachedUserInfo(ref);
  }
}

String _$cachedUserInfoHash() => r'b63eed77d13a9b14b497c5b8c39e5bf9bb556d07';

/// Provider to clear cached user info (useful on logout)

@ProviderFor(clearUserInfoCache)
const clearUserInfoCacheProvider = ClearUserInfoCacheProvider._();

/// Provider to clear cached user info (useful on logout)

final class ClearUserInfoCacheProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider to clear cached user info (useful on logout)
  const ClearUserInfoCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearUserInfoCacheProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearUserInfoCacheHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return clearUserInfoCache(ref);
  }
}

String _$clearUserInfoCacheHash() =>
    r'5d3b96ce34c19201772b04455574f6c804cbeb5b';
