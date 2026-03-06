import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// A single shared [InternetConnection] instance used by both the reactive
/// stream and one-off awaitable checks in the request/auth paths.
@Riverpod(keepAlive: true)
InternetConnection internetConnection(Ref ref) {
  return InternetConnection.createInstance();
}

/// Streams `true` when the device has internet access, `false` when offline.
///
/// Starts with an immediate check so the value is available on first build.
/// Kept alive so all providers share a single subscription.
@Riverpod(keepAlive: true)
Stream<bool> connectivity(Ref ref) async* {
  final checker = ref.watch(internetConnectionProvider);

  yield await checker.hasInternetAccess;

  await for (final status in checker.onStatusChange) {
    yield status == InternetStatus.connected;
  }
}

/// Awaitable connectivity check using the shared [InternetConnection] instance.
///
/// Use this in request and auth paths where you need a reliable answer.
/// Unlike [isDefinitelyOffline], this always reflects the actual current state
/// because it awaits a probe rather than reading the stream's last cached value.
Future<bool> checkOnline(Ref ref) {
  return ref.read(internetConnectionProvider).hasInternetAccess;
}

/// Synchronous helper — returns `false` only when connectivity is explicitly
/// known to be absent from the stream's last emitted value.
///
/// Safe for UI gating but **not** reliable at startup before the stream has
/// emitted its first value. Use [checkOnline] in request/auth paths instead.
bool isDefinitelyOffline(Ref ref) {
  return ref.read(connectivityProvider).value == false;
}
