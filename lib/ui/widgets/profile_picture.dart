import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/cached_user_info_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfilePicture extends ConsumerWidget {
  final double size;
  final String? fallbackText;

  const ProfilePicture({super.key, this.size = 16, this.fallbackText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(cachedUserInfoProvider);

    return asyncUser.when(
      loading: () => SizedBox(
        width: size * 2,
        height: size * 2,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (err, stack) => CircleAvatar(
        radius: size,
        backgroundColor: Theme.of(context).colorScheme.error,
        child: Icon(
          Symbols.error_rounded,
          size: size,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      data: (user) {
        final Uint8List? photo = user?.photo;
        if (photo != null) {
          return CircleAvatar(
            radius: size,
            backgroundImage: MemoryImage(photo),
          );
        }

        final display =
            fallbackText ??
            (user?.name?.trim().isNotEmpty == true
                ? user!.name!.characters.first.toUpperCase()
                : '?');

        return CircleAvatar(
          radius: size,
          child: Text(
            display,
            style: TextStyle(fontSize: size * 0.9, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}
