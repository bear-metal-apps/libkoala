import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfilePicture extends StatefulWidget {
  final double size;
  final Client client;
  final String? fallbackText;

  const ProfilePicture({
    super.key,
    this.size = 16,
    required this.client,
    this.fallbackText,
  });

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = Avatars(widget.client).getInitials(height: 192);
  }

  @override
  void didUpdateWidget(ProfilePicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client) {
      _future = Avatars(widget.client).getInitials(height: 192);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // They see me loadin'
          return SizedBox(
            width: widget.size * 2, // x2 because CircleAvatar uses radius
            height: widget.size * 2, // same here
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          // Show profile picture
          return CircleAvatar(
            radius: widget.size,
            backgroundImage: MemoryImage(snapshot.data!),
          );
        } else {
          // Show error icon if we can't load the picture (typically due to being a guest)
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
