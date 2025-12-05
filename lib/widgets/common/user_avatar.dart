import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color backgroundColor;
  final IconData fallbackIcon;
  final Color iconColor;
  final double iconSize;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    required this.backgroundColor,
    this.fallbackIcon = Icons.person,
    required this.iconColor,
    this.iconSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                httpHeaders: const {
                  'Accept': 'image/*',
                },
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 100),
                maxWidthDiskCache: 1000,
                maxHeightDiskCache: 1000,
                placeholder: (context, url) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: backgroundColor,
                  child: Icon(
                    fallbackIcon,
                    color: iconColor,
                    size: iconSize,
                  ),
                ),
                errorWidget: (context, url, error) {
                  // Log para debugging en desarrollo
                  debugPrint('Error loading profile image from S3: $error');
                  debugPrint('Image URL: $url');
                  return Container(
                    width: radius * 2,
                    height: radius * 2,
                    color: backgroundColor,
                    child: Icon(
                      fallbackIcon,
                      color: iconColor,
                      size: iconSize,
                    ),
                  );
                },
              ),
            )
          : Icon(
              fallbackIcon,
              color: iconColor,
              size: iconSize,
            ),
    );
  }
}

