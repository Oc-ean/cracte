import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

class FavouriteIconButton extends StatelessWidget {
  final Recipe recipe;
  final BoxConstraints? constraints;
  final EdgeInsets? padding;

  const FavouriteIconButton({
    super.key,
    required this.recipe,
    this.constraints,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavouriteRecipeCubit, List<FavouriteRecipe>>(
      bloc: getIt<FavouriteRecipeCubit>(),
      builder: (context, state) {
        final isInFavoritesList =
            state.any((favorite) => favorite.recipe.id == recipe.id);

        final isFavourite =
            state.isEmpty ? recipe.isFavorite : isInFavoritesList;

        return GestureDetector(
          onTap: () {
            if (isFavourite) {
              getIt<FavouriteRecipeCubit>().removeFavourite(recipe);
            } else {
              getIt<FavouriteRecipeCubit>().addFavourite(recipe);
            }
            lightHapticImpact();
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isFavourite! ? SolarIconsBold.heart : SolarIconsOutline.heart,
                  size: 18,
                  key: ValueKey<bool>(isFavourite),
                  color: isFavourite ? Colors.red : Colors.grey.shade500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
