import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/user_info_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfilePicture extends ConsumerStatefulWidget {
  final double size;
  final String? fallbackText;

  const ProfilePicture({super.key, this.size = 16, this.fallbackText});

  @override
  ConsumerState<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends ConsumerState<ProfilePicture> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = _getProfilePhoto();
  }

  Future<Uint8List?> _getProfilePhoto() async {
    final userInfo = await ref.read(userInfoProvider.future);
    return userInfo.profilePhoto;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: widget.size * 2,
            height: widget.size * 2,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            radius: widget.size,
            backgroundImage: MemoryImage(snapshot.data!),
          );
        } else {
          return CircleAvatar(
            radius: widget.size,
            backgroundColor: Theme.of(context).colorScheme.error,
            child: Icon(
              Symbols.error_rounded,
              size: widget.size,
              color: Theme.of(context).colorScheme.onError,
            ),
          );
        }
      },
    );
  }
}
