import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          SolarIconsOutline.addCircle,
          color: context.theme.primaryColor,
        ),
        tooltip: 'Add item',
      ),
    );
  }
}
