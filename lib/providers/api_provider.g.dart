// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
const dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'96a8ec5b5bd68e26771561f6c4c5a184ebcecf85';

@ProviderFor(getData)
const getDataProvider = GetDataFamily._();

final class GetDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  const GetDataProvider._({
    required GetDataFamily super.from,
    required ({String endpoint, bool forceRefresh}) super.argument,
  }) : super(
         retry: null,
         name: r'getDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getDataHash();

  @override
  String toString() {
    return r'getDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as ({String endpoint, bool forceRefresh});
    return getData(
      ref,
      endpoint: argument.endpoint,
      forceRefresh: argument.forceRefresh,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getDataHash() => r'8dcab46fc866b40b156b1356dfe3ddf025d14a99';

final class GetDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, dynamic>>,
          ({String endpoint, bool forceRefresh})
        > {
  const GetDataFamily._()
    : super(
        retry: null,
        name: r'getDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetDataProvider call({required String endpoint, bool forceRefresh = false}) =>
      GetDataProvider._(
        argument: (endpoint: endpoint, forceRefresh: forceRefresh),
        from: this,
      );

  @override
  String toString() => r'getDataProvider';
}

@ProviderFor(getListData)
const getListDataProvider = GetListDataFamily._();

final class GetListDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const GetListDataProvider._({
    required GetListDataFamily super.from,
    required ({String endpoint, bool forceRefresh}) super.argument,
  }) : super(
         retry: null,
         name: r'getListDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getListDataHash();

  @override
  String toString() {
    return r'getListDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    final argument = this.argument as ({String endpoint, bool forceRefresh});
    return getListData(
      ref,
      endpoint: argument.endpoint,
      forceRefresh: argument.forceRefresh,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetListDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getListDataHash() => r'6795f96c3903764949cb66add4c43155c3979d1f';

final class GetListDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<dynamic>>,
          ({String endpoint, bool forceRefresh})
        > {
  const GetListDataFamily._()
    : super(
        retry: null,
        name: r'getListDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetListDataProvider call({
    required String endpoint,
    bool forceRefresh = false,
  }) => GetListDataProvider._(
    argument: (endpoint: endpoint, forceRefresh: forceRefresh),
    from: this,
  );

  @override
  String toString() => r'getListDataProvider';
}
