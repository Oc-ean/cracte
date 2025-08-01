import 'dart:io';

import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

class ImagePickerCard extends StatelessWidget {
  final File? selectedImage;
  final String? existingImage;
  final VoidCallback onTap;

  const ImagePickerCard({
    required this.selectedImage,
    required this.existingImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.theme.cardColor,
          border: Border.all(
            color: context.isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          SolarIconsOutline.camera,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : existingImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CustomImage(
                      imagePath: existingImage!,
                      width: double.infinity,
                      height: double.infinity,
                      boxShape: BoxShape.rectangle,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              context.theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          SolarIconsOutline.camera,
                          size: 32,
                          color: context.theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Add Recipe Photo',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to select an image',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
