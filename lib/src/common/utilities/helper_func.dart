import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestGalleryPermission(BuildContext context) async {
  final status = await Permission.photos.request();

  if (status.isGranted) {
    logman.info('Gallery permission granted');
    return true;
  } else if (status.isPermanentlyDenied) {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Gallery access is needed to choose a profile picture. Open app profile to allow access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (open == true) {
      await openAppSettings();
    }
    return false;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permission denied. Cannot pick image.')),
    );
    return false;
  }
}

List<Recipe> sortRecipe(List<Recipe> recipes) {
  return List<Recipe>.from(recipes)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
