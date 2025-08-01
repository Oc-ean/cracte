import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isExpanded = false;
  late final UserCubit _userCubit;
  late final UserRecipeCubit _userRecipeCubit;

  @override
  void initState() {
    super.initState();
    _userCubit = getIt<UserCubit>();
    _userRecipeCubit = UserRecipeCubit(
      userRecipeRepository: getIt<UserRecipeRepository>(),
    );
    _userCubit.getUser();
    _userRecipeCubit.getUserRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          BlocBuilder<UserCubit, UserState>(
            bloc: _userCubit,
            builder: (context, state) {
              final user = state is UserLoaded ? state.user : User.sampleData();
              return Skeletonizer(
                enabled: state is UserLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: context.theme.cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomImage(
                              imagePath: user.photoUrl,
                              height: 80,
                              width: 80,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ProfileInfoRow(
                                title: 'Recipes',
                                subtitle: user.recipes.toString(),
                              ),
                              _ProfileInfoRow(
                                title: 'Followers',
                                subtitle: user.followers.length.toString(),
                              ),
                              _ProfileInfoRow(
                                title: 'Following',
                                subtitle: user.following.length.toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user.name,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    AnimatedCrossFade(
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                      firstChild: Text(
                        user.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(user.bio),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'Show less' : 'Show more',
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          color: context.theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'My recipes',
            style: context.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<UserRecipeCubit, UserRecipeState>(
            bloc: _userRecipeCubit,
            builder: (context, state) {
              final recipes = state is UserRecipeLoaded
                  ? state.recipes
                  : List.generate(3, (index) => Recipe.sampleData());

              if (state is UserRecipeEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recipes yet',
                        style: context.theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                );
              }
              return Skeletonizer(
                enabled: state is UserRecipeLoading,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: HorizontalRecipeCard(
                        recipe: recipes[index],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ProfileInfoRow({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: context.theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
