import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final String? targetUserName;
  final String? targetUserImage;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    super.key,
    required this.targetUserId,
    this.onFollowChanged,
    this.targetUserName,
    this.targetUserImage,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late final FollowCubit _followCubit;

  @override
  void initState() {
    super.initState();
    _followCubit = getIt<FollowCubit>();
    _followCubit.loadFollowStatus(widget.targetUserId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowCubit, FollowState>(
      bloc: _followCubit,
      builder: (context, state) {
        final (isLoading, isFollowing) = _getButtonState(state);

        return CustomButton(
          loading: isLoading,
          text: isFollowing ? 'Following' : 'Follow',
          height: 37,
          width: 85,
          boxRadius: 9,
          fontSize: 14,
          onTap: _handleFollowToggle,
        );
      },
    );
  }

  (bool isLoading, bool isFollowing) _getButtonState(FollowState state) {
    switch (state) {
      case FollowLoading():
        return (true, _getPreviousFollowStatus());
      case FollowLoaded():
        return (false, state.followingStatus[widget.targetUserId] ?? false);
      case FollowError():
        return (false, _getPreviousFollowStatus());
      default:
        return (false, false);
    }
  }

  bool _getPreviousFollowStatus() {
    final currentState = _followCubit.state;
    if (currentState is FollowLoaded) {
      return currentState.followingStatus[widget.targetUserId] ?? false;
    }
    return false;
  }

  Future<void> _handleFollowToggle() async {
    try {
      await _followCubit.toggleFollow(
          widget.targetUserId, widget.targetUserName, widget.targetUserImage,);
      widget.onFollowChanged?.call();
    } catch (e) {
      // Handle error if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_getPreviousFollowStatus() ? 'unfollow' : 'follow'} user',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
