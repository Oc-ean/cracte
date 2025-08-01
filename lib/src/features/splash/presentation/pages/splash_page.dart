import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logman.attachOverlay(
        context: context,
      );
    });
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    final user = await getIt<UserRepository>().getCurrentUser();

    if (user != null) {
      context.pushReplacement(Routes.home.path);
    } else {
      context.pushReplacement(Routes.signUp.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 20),
            Text(
              appName,
              style: context.textTheme.titleLarge?.withColor(
                Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
