// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getApiKey)
const getApiKeyProvider = GetApiKeyProvider._();

final class GetApiKeyProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const GetApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getApiKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getApiKeyHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return getApiKey(ref);
  }
}

String _$getApiKeyHash() => r'054573bce12ee856c7037ec5b1340a57c2fd3fd5';
