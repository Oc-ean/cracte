import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:solar_icons/solar_icons.dart';

class StepField extends StatelessWidget {
  final int index;
  final FormControl<String> formControl;
  final VoidCallback? onRemove;

  const StepField({
    super.key,
    required this.index,
    required this.formControl,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: context.theme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${index + 1}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                ReactiveTextField<String>(
                  formControl: formControl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe this cooking step...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: context.isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  SolarIconsOutline.trashBin2,
                  color: Colors.red,
                  size: 20,
                ),
                tooltip: 'Remove step',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
