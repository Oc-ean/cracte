import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late CategoryCubit _categoryCubit;

  int _currentIndex = 0;

  final FormGroup formGroup = fb.group({
    FormControlName.search: FormControl<String>(),
  });

  @override
  void initState() {
    super.initState();
    _categoryCubit = CategoryCubit(
      repository: getIt<CategoryRepository>(),
      recipeRepository: getIt<RecipeRepository>(),
    );
    _tabController = TabController(length: 4, vsync: this);
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    _tabController.animateTo(index);
    lightHapticImpact();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: BlocConsumer<CategoryCubit, CategoryState>(
            bloc: _categoryCubit,
            listener: (context, state) {
              if (state is CategoryLoaded) {
                final categories = state.categories;

                print('categories: ${categories.length}');
                _tabController = TabController(
                  length: categories.length,
                  vsync: this,
                );
              }
            },
            builder: (context, state) {
              final categories = state is CategoryLoaded
                  ? state.categories
                  : List<Category>.generate(
                      4,
                      (index) => Category.sampleData(),
                    );
              return Skeletonizer(
                enabled: state is CategoryLoading,
                child: StyledSegmentedTabs(
                  height: 45,
                  tabs: categories
                      .map((c) => StyledSegmentedTab(key: c.id, label: c.name))
                      .toList(),
                  currentIndex: _currentIndex,
                  onTabChanged: _onTabChanged,
                  tabController: _tabController,
                  isScrollable: true,
                ),
              );
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TabBarView(
          controller: _tabController,
          children: categories
              .map(
                (cat) => CategoryList(
                  categoryId: cat.id,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  final String categoryId;
  const CategoryList({super.key, required this.categoryId});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late final CategoryRecipeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CategoryRecipeCubit(
      recipeRepository: getIt<RecipeRepository>(),
      categoryId: widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryRecipeCubit, CategoryRecipeState>(
      bloc: _cubit,
      builder: (context, state) {
        final categories = state is CategoryRecipeLoaded
            ? state.recipes
            : List<Recipe>.generate(5, (index) => Recipe.sampleData());
        return Skeletonizer(
          enabled: state is CategoryRecipeLoading,
          child: ListView.separated(
            itemCount: sortRecipe(categories).length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final recipe = sortRecipe(categories)[index];
              return GestureDetector(
                onTap: () => context.push(
                  Routes.details.path,
                  extra: {
                    'recipe': recipe,
                  },
                ),
                child: HorizontalRecipeCard(
                  recipe: recipe,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
