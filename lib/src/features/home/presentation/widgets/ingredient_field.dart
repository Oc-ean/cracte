import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:solar_icons/solar_icons.dart';

class IngredientField extends StatelessWidget {
  final int index;
  final FormControl<String> formControl;
  final VoidCallback? onRemove;

  const IngredientField({
    super.key,
    required this.index,
    required this.formControl,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: context.theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ReactiveTextField<String>(
              formControl: formControl,
              decoration: InputDecoration(
                hintText: 'Enter ingredient',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: context.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade50,
              ),
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                SolarIconsOutline.trashBin2,
                color: Colors.red,
                size: 20,
              ),
              tooltip: 'Remove ingredient',
            ),
          ],
        ],
      ),
    );
  }
}
