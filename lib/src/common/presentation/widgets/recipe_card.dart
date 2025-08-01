import 'package:cracte/src/common/common.dart';
import 'package:cracte/src/features/features.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: context.theme.cardColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Text(
                        recipe.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      recipe.category.name,
                      maxLines: 1,
                      style: context.textTheme.titleLarge?.copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                        color: context.theme.textTheme.bodyLarge!.color!
                            .withValues(alpha: 0.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '${recipe.duration} min',
                          maxLines: 1,
                          style: context.textTheme.titleLarge?.copyWith(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 13,
                            color: context.theme.textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.topRight,
                          child: FavouriteIconButton(recipe: recipe),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: CustomImage(imagePath: recipe.image),
            ),
          ],
        ),
      ),
    );
  }
}
