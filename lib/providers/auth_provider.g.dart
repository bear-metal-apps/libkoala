// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthStatusNotifier)
const authStatusProvider = AuthStatusNotifierProvider._();

final class AuthStatusNotifierProvider
    extends $NotifierProvider<AuthStatusNotifier, AuthStatus> {
  const AuthStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusNotifierHash();

  @$internal
  @override
  AuthStatusNotifier create() => AuthStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStatus>(value),
    );
  }
}

String _$authStatusNotifierHash() =>
    r'e1ea086604227f20c0eec31221da6c6fedabca20';

abstract class _$AuthStatusNotifier extends $Notifier<AuthStatus> {
  AuthStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthStatus, AuthStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStatus, AuthStatus>,
              AuthStatus,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(auth)
const authProvider = AuthProvider._();

final class AuthProvider extends $FunctionalProvider<Auth, Auth, Auth>
    with $Provider<Auth> {
  const AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  $ProviderElement<Auth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Auth create(Ref ref) {
    return auth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Auth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Auth>(value),
    );
  }
}

String _$authHash() => r'4c5bd603ebfee851fba77db373c8c1c0133ab6ab';
