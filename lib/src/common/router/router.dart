import 'package:cracte/src/common/common.dart';
import 'package:cracte/src/features/features.dart';
import 'package:cracte/src/features/home/presentation/pages/recipe_details_page.dart';
import 'package:cracte/src/features/home/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logman/logman.dart';

part 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKeyHome = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorKeyCreate =
    GlobalKey<NavigatorState>(debugLabel: 'explore');
final _shellNavigatorKeyFavourite =
    GlobalKey<NavigatorState>(debugLabel: 'favourite');
final _shellNavigatorKeyProfile =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final router = GoRouter(
  initialLocation: Routes.splash.path,
  navigatorKey: _rootNavigatorKey,
  observers: [
    LogmanNavigatorObserver(),
  ],
  routes: [
    GoRoute(
      path: Routes.splash.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: Routes.signUp.name,
      path: Routes.signUp.path,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      name: Routes.create.name,
      path: Routes.create.path,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final recipe = extra?['recipe'] as Recipe?;
        return CreatePage(
          recipe: recipe,
        );
      },
    ),
    GoRoute(
      name: Routes.details.name,
      path: Routes.details.path,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final recipe = extra['recipe'] as Recipe;
        return RecipeDetailsPage(recipe: recipe);
      },
    ),
    GoRoute(
      name: Routes.cookingMode.name,
      path: Routes.cookingMode.path,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final recipe = extra['recipe'] as Recipe;
        return CookingModePage(recipe: recipe);
      },
    ),
    GoRoute(
      name: Routes.search.name,
      path: Routes.search.path,
      builder: (context, state) {
        return const RecipeSearchPage();
      },
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, navigationShell) {
        return RootPage(
          statefulNavigationShell: navigationShell,
        ).pageTransition(state: state);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyHome,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.home.path,
              name: Routes.home.name,
              pageBuilder: (context, state) {
                return const HomePage().pageTransition(state: state);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyCreate,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.explore.path,
              name: Routes.explore.name,
              pageBuilder: (context, state) {
                return const ExplorePage().pageTransition(state: state);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyFavourite,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.favourite.path,
              name: Routes.favourite.name,
              pageBuilder: (context, state) {
                return const FavouritePage().pageTransition(state: state);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyProfile,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.profile.path,
              name: Routes.profile.name,
              pageBuilder: (context, state) {
                return const ProfilePage().pageTransition(state: state);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
