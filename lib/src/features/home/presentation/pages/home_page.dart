import 'package:cracte/src/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FormGroup formGroup = fb.group({
    FormControlName.search: FormControl<String>(),
  });

  final _scrollController = ScrollController();
  late RecipeCubit _cubit;

  @override
  void initState() {
    super.initState();

    _cubit = getIt<RecipeCubit>();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = _cubit.state;
        if (state is RecipeLoaded && !state.isPaginating) {
          _cubit.fetchMoreRecipes();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: formGroup,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cracte',
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomFormTextField<String>(
                name: FormControlName.search,
                hintText: 'Search recipes',
                readOnly: true,
                textCapitalization: TextCapitalization.none,
                onTap: () => context.push(Routes.search.path),
                prefix: const Icon(CupertinoIcons.search, size: 24),
              ),
            ),
          ),
        ),
        body: BlocBuilder<RecipeCubit, RecipeState>(
          bloc: _cubit,
          builder: (context, state) {
            final recipes = state is RecipeLoaded
                ? state.recipes
                : [
                    Recipe.sampleData(),
                    Recipe.sampleData(),
                    Recipe.sampleData(),
                  ];

            final isPaginating = state is RecipeLoaded && state.isPaginating;
            final sortedRecipes = sortRecipe(recipes);

            return RefreshIndicator(
              onRefresh: () => _cubit.getRecipes(),
              child: Skeletonizer(
                enabled: state is RecipeLoading,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 20),
                    MasonryGridView.count(
                      clipBehavior: Clip.none,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemCount: sortedRecipes.length,
                      itemBuilder: (context, index) => RecipeCard(
                        recipe: sortedRecipes[index],
                        onTap: () => context.push(
                          Routes.details.path,
                          extra: {
                            'recipe': sortRecipe(recipes)[index],
                          },
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isPaginating
                          ? SpinKitThreeBounce(
                              color: context.theme.primaryColor,
                              size: 20,
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: context.theme.primaryColor,
          child: SvgPicture.asset(
            createIcon,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => context.push(Routes.create.path),
        ),
      ),
    );
  }
}
