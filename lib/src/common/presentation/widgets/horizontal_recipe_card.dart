import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HorizontalRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const HorizontalRecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomImage(
              imagePath: recipe.image,
              height: 100,
              width: 100,
              boxShape: BoxShape.rectangle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  recipe.description,
                  maxLines: 1,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(
                      clockIcon,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        context.theme.iconTheme.color!,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${recipe.duration} min',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
