import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;

  const CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: DropdownButtonFormField<Category>(
              value: selectedCategory,
              decoration: const InputDecoration(
                prefixIcon: Icon(SolarIconsOutline.tag),
                hintText: 'Select a category',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(
                    category.name,
                    style: context.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (Category? category) {
                if (category != null) {
                  onCategorySelected(category);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
