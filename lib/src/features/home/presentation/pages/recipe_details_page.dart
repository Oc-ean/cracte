import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Recipe? recipe;
  const RecipeDetailsPage({super.key, this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  String? userId;

  late Recipe? _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.recipe == null) {
        onEditRecipe();
      }
    });
    _tabController = TabController(length: 2, vsync: this);
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

  final List<StyledSegmentedTab> _tabs = [
    const StyledSegmentedTab(key: 'ingredient', label: 'Ingredient'),
    const StyledSegmentedTab(key: 'step', label: 'Step'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const BackIconButton(),
        actions: [
          BlocBuilder<UserCubit, UserState>(
            bloc: getIt<UserCubit>(),
            builder: (context, state) {
              userId = state is UserLoaded ? state.user.id : null;

              print('User id ===> $userId');
              final isOwner =
                  state is UserLoaded && state.user.id == _recipe!.authorId;
              return isOwner
                  ? IconButton(
                      onPressed: onEditRecipe,
                      icon: const Icon(SolarIconsOutline.pen2, size: 20),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomImage(
                      height: 150,
                      width: double.infinity,
                      imagePath: _recipe!.image,
                      boxShape: BoxShape.rectangle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _recipe!.title,
                      style: context.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _recipe!.description,
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 15),
                    _AuthorTiles(
                      authorImage: _recipe!.authorImage,
                      authorName: _recipe!.authorName,
                      authorId: _recipe!.authorId,
                      currentUserId: userId ?? '',
                    ),
                    const SizedBox(height: 20),
                    StyledSegmentedTabs(
                      tabs: _tabs,
                      currentIndex: _currentIndex,
                      onTabChanged: _onTabChanged,
                      tabController: _tabController,
                      showSelectedColor: false,
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _IngredientTab(ingredients: _recipe!.ingredients),
            _StepTab(steps: _recipe!.steps),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomButton(
          height: 45,
          boxRadius: 10,
          width: double.infinity,
          icon: SvgPicture.asset(
            cookingIcon,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          text: 'Start Cooking',
          fontSize: 16,
          onTap: () => context
              .push(Routes.cookingMode.path, extra: {'recipe': widget.recipe}),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> onEditRecipe() async {
    final recipe = await context
        .push(Routes.create.path, extra: {'recipe': widget.recipe}) as Recipe?;

    if (_recipe != null) {
      if (recipe != null && !recipe.isEqualTo(_recipe!)) {
        _recipe = recipe;
        setState(() {});
      }
    }
  }
}

class _IngredientTab extends StatelessWidget {
  final List<String> ingredients;

  const _IngredientTab({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return _IngredientTile(
          ingredient: ingredients[index],
          index: index + 1,
        );
      },
    );
  }
}

class _StepTab extends StatelessWidget {
  final List<String> steps;

  const _StepTab({required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _StepTile(
          step: steps[index],
          stepNumber: index + 1,
        );
      },
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final String ingredient;
  final int index;

  const _IngredientTile({
    required this.ingredient,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
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
                '$index',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              ingredient,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final int stepNumber;

  const _StepTile({
    required this.step,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: context.theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $stepNumber',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorTiles extends StatelessWidget {
  final String authorName;
  final String authorImage;
  final String authorId;
  final String currentUserId;

  const _AuthorTiles({
    required this.authorName,
    required this.authorImage,
    required this.authorId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomImage(
          imagePath: authorImage,
          height: 40,
          width: 40,
        ),
        const SizedBox(width: 10),
        Text(
          authorName,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        if(currentUserId != authorId)
        FollowButton(
          targetUserId: authorId,
          targetUserName: authorName,
          targetUserImage: authorImage,
        ),
      ],
    );
  }
}
