// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userInfo)
const userInfoProvider = UserInfoProvider._();

final class UserInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserInfo?>,
          UserInfo?,
          FutureOr<UserInfo?>
        >
    with $FutureModifier<UserInfo?>, $FutureProvider<UserInfo?> {
  const UserInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userInfoHash();

  @$internal
  @override
  $FutureProviderElement<UserInfo?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserInfo?> create(Ref ref) {
    return userInfo(ref);
  }
}

String _$userInfoHash() => r'c8ae4d5d3bb5b8fe59c4e102604ec0c9ff5ceae9';
