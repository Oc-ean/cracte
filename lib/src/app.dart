import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentAppThemeCubit, CurrentAppTheme>(
      bloc: getIt<CurrentAppThemeCubit>(),
      builder: (context, currentAppTheme) {
        return MaterialApp.router(
          routerConfig: router,
          // routerDelegate: router.routerDelegate,
          title: 'Pronto',
          darkTheme: darkTheme,
          theme: lightTheme,
          themeMode: currentAppTheme.themeMode,
        );
      },
    );
  }
}
