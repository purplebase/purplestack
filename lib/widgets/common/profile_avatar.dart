import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:models/models.dart';

class ProfileAvatar extends StatelessWidget {
  final Profile? profile;
  final double radius;
  final List<Color>? borderColors;

  const ProfileAvatar({
    super.key,
    this.profile,
    this.radius = 24,
    this.borderColors,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackColor = borderColors!.first;

    Widget avatar = ClipOval(
      child: profile?.pictureUrl != null
          ? CachedNetworkImage(
              imageUrl: profile!.pictureUrl!,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              placeholder: (context, url) => Container(
                color: fallbackColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: fallbackColor,
                  size: radius * 0.8,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: fallbackColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: fallbackColor,
                  size: radius * 0.8,
                ),
              ),
            )
          : Container(
              width: radius * 2,
              height: radius * 2,
              color: fallbackColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: fallbackColor,
                size: radius * 0.8,
              ),
            ),
    );

    if (borderColors != null) {
      return Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: borderColors!),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: avatar,
        ),
      );
    }

    return avatar;
  }
}
