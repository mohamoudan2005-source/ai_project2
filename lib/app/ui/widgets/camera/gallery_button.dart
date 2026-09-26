import 'package:flutter/material.dart';
import 'package:ai_project/utils/app_theme.dart';

class GalleryButton extends StatelessWidget {
  final VoidCallback onTap;
  const GalleryButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.galleryBtn,
        height: AppSizes.galleryBtn,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          Icons.photo_library_outlined,
          color: AppColors.textMain,
          size: AppSizes.iconLg,
        ),
      ),
    );
  }
}
