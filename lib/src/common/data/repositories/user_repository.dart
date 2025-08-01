import 'dart:async';

import 'package:cracte/src/common/common.dart';

class UserRepository {
  final UserDataSource _dataSource;

  UserRepository({
    required UserDataSource dataSource,
  }) : _dataSource = dataSource;
  Future<User?> getCurrentUser() async {
    try {
      return await _dataSource.getCurrentUser();
    } catch (e, s) {
      logman.error('Failed to get current user: $e', stackTrace: s);
      return null;
    }
  }

  Stream<User?> getCurrentUserStream() {
    return _dataSource.getCurrentUserStream();
  }

  Future<void> saveCurrentUser(User user) async {
    try {
      await _dataSource.saveCurrentUser(user);
    } catch (e, s) {
      logman.error('Failed to save current user: $e', stackTrace: s);
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      return await _dataSource.getUserById(userId);
    } catch (e, s) {
      logman.error('Failed to get user by ID: $e', stackTrace: s);
      return null;
    }
  }

  Future<bool> followUser(
    String targetUserId,
    String? targetUserName,
    String? targetUserImage,
  ) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null || currentUser.id == targetUserId) {
        return false;
      }

      return await _dataSource.followUser(
        currentUser.id,
        targetUserId,
        targetUserName: targetUserName,
        targetUserImage: targetUserImage,
      );
    } catch (e, s) {
      logman.error('Failed to follow user: $e', stackTrace: s);
      return false;
    }
  }

  Future<bool> unfollowUser(String targetUserId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      return await _dataSource.unfollowUser(currentUser.id, targetUserId);
    } catch (e, s) {
      logman.error('Failed to unfollow user: $e', stackTrace: s);
      return false;
    }
  }

  Future<bool> isFollowing(String targetUserId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      return currentUser.isFollowing(targetUserId);
    } catch (e, s) {
      logman.error('Failed to check if following: $e', stackTrace: s);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dataSource.deleteCurrentUser();
    } catch (e, s) {
      logman.error('Failed to logout: $e', stackTrace: s);
    }
  }
}
