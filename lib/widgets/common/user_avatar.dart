import 'package:flutter/material.dart';

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
          ? _buildNetworkImage(imageUrl!)
          : Icon(
              fallbackIcon,
              color: iconColor,
              size: iconSize,
            ),
    );
  }

  // Widget para cargar imagen desde URL (funciona en Web, Android e iOS)
  Widget _buildNetworkImage(String imageUrl) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: radius * 2,
            height: radius * 2,
            color: backgroundColor,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultIcon() {
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
  }
}
