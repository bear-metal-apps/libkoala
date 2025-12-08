// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(graphql)
const graphqlProvider = GraphqlProvider._();

final class GraphqlProvider
    extends
        $FunctionalProvider<
          AsyncValue<GraphQLClient>,
          GraphQLClient,
          FutureOr<GraphQLClient>
        >
    with $FutureModifier<GraphQLClient>, $FutureProvider<GraphQLClient> {
  const GraphqlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'graphqlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$graphqlHash();

  @$internal
  @override
  $FutureProviderElement<GraphQLClient> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GraphQLClient> create(Ref ref) {
    return graphql(ref);
  }
}

String _$graphqlHash() => r'19f184d2d4e10e2fad0cbf491690301cc1eb37ed';
