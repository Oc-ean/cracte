import 'dart:async';
import 'package:cracte/src/common/common.dart';
import 'package:hive/hive.dart';

class UserDataSource {
  final Box<User> _currentUserBox;
  final Box<User> _allUsersBox;
  final StreamController<User?> _currentUserController =
      StreamController<User?>.broadcast();
  final StreamController<List<User>> _allUsersController =
      StreamController<List<User>>.broadcast();

  UserDataSource()
      : _currentUserBox = Hive.box<User>('current_user'),
        _allUsersBox = Hive.box<User>('users');

  Future<void> saveCurrentUser(User user) async {
    try {
      await _currentUserBox.put('current', user);
      _currentUserController.add(user);
      await _updateUserInAllUsers(user);
    } catch (e) {
      logman.error('Failed to save current user: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      return _currentUserBox.get('current');
    } catch (e) {
      logman.error('Failed to get current user: $e');
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      return _allUsersBox.values.toList();
    } catch (e) {
      logman.error('Failed to get all users: $e');
      return [];
    }
  }

  Future<void> saveAllUsers(List<User> users) async {
    try {
      await _allUsersBox.clear();
      await _allUsersBox.addAll(users);
      _allUsersController.add(users);
    } catch (e) {
      logman.error('Failed to save all users: $e');
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      return _allUsersBox.values.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw StateError('User not found'),
      );
    } catch (e) {
      logman.error('Failed to get user by ID: $e');
      return null;
    }
  }

  Future<User?> _getDummyUserFromRecipes(String userId) async {
    try {
      final recipes = await getIt<RecipeRepository>().getRecipes();
      for (final recipe in recipes) {
        if (recipe.authorId == userId) {
          return User(
            id: recipe.authorId,
            name: recipe.authorName,
            email:
                '${recipe.authorName.toLowerCase().replaceAll(' ', '.')}@dummy.com',
            photoUrl: recipe.authorImage,
            bio: 'Recipe author',
            following: [],
            followers: [],
            isDummy: true,
          );
        }
      }
      return null;
    } catch (e) {
      logman.error('Failed to get dummy user from recipes: $e');
      return null;
    }
  }

  Future<User> _createDummyUser(String userId,
      {String? name, String? image}) async {
    return User(
      id: userId,
      name: name ?? 'Unknown User',
      email: '${name?.toLowerCase().replaceAll(' ', '.') ?? 'user'}@dummy.com',
      photoUrl: image ?? '',
      bio: 'Recipe author',
      following: [],
      followers: [],
      isDummy: true,
    );
  }

  Future<bool> followUser(
    String currentUserId,
    String targetUserId, {
    String? targetUserName,
    String? targetUserImage,
  }) async {
    try {
      final users = await getAllUsers();
      final currentUser = users.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => throw StateError('Current user not found'),
      );

      if (currentUser.isFollowing(targetUserId)) {
        logman.error('Already following this user');
        return false;
      }

      User targetUser;
      try {
        targetUser = users.firstWhere((u) => u.id == targetUserId);
      } catch (_) {
        final existingDummyUser = await _getDummyUserFromRecipes(targetUserId);
        targetUser = existingDummyUser ??
            await _createDummyUser(
              targetUserId,
              name: targetUserName,
              image: targetUserImage,
            );
        users.add(targetUser);
      }

      final updatedCurrentUser = currentUser.copyWith(
        following: [...currentUser.following, targetUserId],
      );

      final updatedTargetUser = targetUser.copyWith(
        followers: [...targetUser.followers, currentUserId],
      );

      final updatedUsers = users
          .asMap()
          .map((index, user) => MapEntry(
              index,
              user.id == currentUserId
                  ? updatedCurrentUser
                  : user.id == targetUserId
                      ? updatedTargetUser
                      : user))
          .values
          .toList();

      await saveAllUsers(updatedUsers);

      if (currentUserId == (await getCurrentUser())?.id) {
        await saveCurrentUser(updatedCurrentUser);
      }

      return true;
    } catch (e) {
      logman.error('Failed to follow user: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      final users = await getAllUsers();
      final currentUser = users.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => throw StateError('Current user not found'),
      );

      if (!currentUser.isFollowing(targetUserId)) {
        logman.error('Not following this user');
        return false;
      }

      final updatedCurrentUser = currentUser.copyWith(
        following:
            currentUser.following.where((id) => id != targetUserId).toList(),
      );

      final updatedUsers = users
          .asMap()
          .map((index, user) {
            if (user.id == currentUserId) {
              return MapEntry(index, updatedCurrentUser);
            }
            if (user.id == targetUserId) {
              return MapEntry(
                  index,
                  user.copyWith(
                    followers: user.followers
                        .where((id) => id != currentUserId)
                        .toList(),
                  ));
            }
            return MapEntry(index, user);
          })
          .values
          .toList();

      await saveAllUsers(updatedUsers);

      if (currentUserId == (await getCurrentUser())?.id) {
        await saveCurrentUser(updatedCurrentUser);
      }

      return true;
    } catch (e) {
      logman.error('Failed to unfollow user: $e');
      return false;
    }
  }

  Future<void> _updateUserInAllUsers(User user) async {
    try {
      final users = await getAllUsers();
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user;
      } else {
        users.add(user);
      }
      await saveAllUsers(users);
    } catch (e) {
      logman.error('Failed to update user in all users: $e');
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      await _currentUserBox.delete('current');
      _currentUserController.add(null);
    } catch (e) {
      logman.error('Failed to delete current user: $e');
    }
  }

  Stream<User?> getCurrentUserStream() => _currentUserController.stream;
  Stream<List<User>> getAllUsersStream() => _allUsersController.stream;

  void dispose() {
    _currentUserController.close();
    _allUsersController.close();
  }
}
