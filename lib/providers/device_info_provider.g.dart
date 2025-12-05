// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceInfo)
const deviceInfoProvider = DeviceInfoProvider._();

final class DeviceInfoProvider
    extends $FunctionalProvider<DeviceInfo, DeviceInfo, DeviceInfo>
    with $Provider<DeviceInfo> {
  const DeviceInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceInfoHash();

  @$internal
  @override
  $ProviderElement<DeviceInfo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceInfo create(Ref ref) {
    return deviceInfo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceInfo>(value),
    );
  }
}

String _$deviceInfoHash() => r'389ea78d0e84c7979345b2015e10dcc168fe8484';
