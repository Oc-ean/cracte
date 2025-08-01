import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomErrorWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomErrorWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(emptyLottie, height: 300, width: 300),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Something went wrong'),
            const SizedBox(width: 30),
            TextButton.icon(
              onPressed: onPressed,
              label: const Text('Retry'),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    );
  }
}
