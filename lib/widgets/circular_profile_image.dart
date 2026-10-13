import 'dart:ui' as ui;

import 'package:ai_project/utils/app_theme.dart';
import 'package:flutter/material.dart';

class CircularProfileImage extends StatelessWidget {
  const CircularProfileImage({
    required this.imageUrl,
    required this.fallback,
    this.loading,
    super.key,
  });

  final String imageUrl;
  final Widget fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Image.network(
                imageUrl,
                key: ValueKey('profile-background-$imageUrl'),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: AppColors.card),
              ),
            ),
            Image.network(
              imageUrl,
              key: ValueKey('profile-foreground-$imageUrl'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded ||
                    frame != null ||
                    loading == null) {
                  return child;
                }
                return loading!;
              },
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
          ],
        ),
      ),
    );
  }
}
