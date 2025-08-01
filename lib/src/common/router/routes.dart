part of 'router.dart';

enum Routes {
  splash('Splash', '/'),
  signUp('Sign Up', '/signUp'),
  home('Home', '/home'),
  search('Search', '/search'),
  create('Create', '/create'),
  explore('Explore', '/explore'),
  details('Details', '/Details'),
  favourite('Favourite', '/favourite'),
  cookingMode('Cooking Mode', '/cookingMode'),
  profile('Profile', '/profile');

  final String name;
  final String path;

  const Routes(this.name, this.path);
}
