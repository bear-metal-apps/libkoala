import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:libkoala/providers/api_key_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'graphql_provider.g.dart';

@Riverpod(keepAlive: true)
GraphQLClient graphql(Ref ref) {
  ref.read(getApiKeyProvider).value;
  final link = HttpLink(
    "https://bearnet-fwgjeng4hxbshzhw.westus2-01.azurewebsites.net/api/graphql",
    defaultHeaders: {"X-Api-Key": ref.read(getApiKeyProvider).value ?? ""},
  );

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: HiveStore()),
  );
}
