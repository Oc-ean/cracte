import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DummyLoadingPostLists extends StatelessWidget {
  const DummyLoadingPostLists({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Recipe> recipe = [
      Recipe.sampleData(),
      Recipe.sampleData(),
      Recipe.sampleData(),
    ];
    return Skeletonizer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: recipe.length,
        itemBuilder: (context, index) {
          return HorizontalRecipeCard(recipe: recipe[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 20),
      ),
    );
  }
}
