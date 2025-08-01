import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'follow_state.dart';

class FollowCubit extends Cubit<FollowState> {
  final UserRepository _userRepository;

  FollowCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(FollowInitial());

  final Map<String, bool> _followingStatus = {};

  Future<void> loadFollowStatus(String userId) async {
    emit(FollowLoading());
    try {
      final isFollowing = await _userRepository.isFollowing(userId);
      _followingStatus[userId] = isFollowing;
      emit(FollowLoaded(Map.from(_followingStatus)));
    } catch (e) {
      emit(const FollowError('Failed to load follow status'));
    }
  }

  Future<void> toggleFollow(
      String userId, String? userName, String? userImage,) async {
    final isFollowing = _followingStatus[userId] ?? false;
    if (isFollowing) {
      await unfollowUser(userId);
    } else {
      await followUser(userId, userName, userImage);
    }
  }

  Future<void> followUser(
      String userId, String? userName, String? userImage,) async {
    emit(FollowLoading());
    try {
      final success =
          await _userRepository.followUser(userId, userName, userImage);
      if (success) {
        _followingStatus[userId] = true;
        emit(FollowLoaded(Map.from(_followingStatus)));
      } else {
        emit(const FollowError('Failed to follow user'));
      }
    } catch (e) {
      emit(FollowError('An error occurred: $e'));
    }
  }

  Future<void> unfollowUser(String userId) async {
    emit(FollowLoading());
    try {
      final success = await _userRepository.unfollowUser(userId);
      if (success) {
        _followingStatus[userId] = false;
        emit(FollowLoaded(Map.from(_followingStatus)));
      } else {
        emit(const FollowError('Failed to unfollow user'));
      }
    } catch (e) {
      emit(FollowError('An error occurred: $e'));
    }
  }

  bool isFollowing(String userId) {
    return _followingStatus[userId] ?? false;
  }
}
