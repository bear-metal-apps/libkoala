import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

class TeamLogo extends StatefulWidget {
  final int teamNumber;
  final double size;
  final Client client;
  final String? fallbackText;

  const TeamLogo({
    super.key,
    required this.teamNumber,
    this.size = 16,
    required this.client,
    this.fallbackText,
  });

  @override
  State<TeamLogo> createState() => _TeamLogoState();
}

class _TeamLogoState extends State<TeamLogo> {
  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = Avatars(widget.client).getImage(
      url:
          'https://www.thebluealliance.com/avatar/2025/frc${widget.teamNumber}.png',
      width: widget.size.toInt(),
      height: widget.size.toInt(),
    );
  }

  @override
  void didUpdateWidget(TeamLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client ||
        oldWidget.teamNumber != widget.teamNumber ||
        oldWidget.size != widget.size) {
      _future = Avatars(widget.client).getImage(
        url:
            'https://www.thebluealliance.com/avatar/2025/frc${widget.teamNumber}.png',
        width: widget.size.toInt(),
        height: widget.size.toInt(),
      );
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
          // Show team logo
          return CircleAvatar(
            radius: widget.size,
            backgroundImage: MemoryImage(snapshot.data!),
          );
        } else {
          // Set to fallback text if we can't load the logo
          return CircleAvatar(
            radius: widget.size,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: widget.fallbackText != null
                ? Text(
                    widget.fallbackText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: widget.size / 3,
                    ),
                  )
                : null,
          );
        }
      },
    );
  }
}
