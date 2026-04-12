import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/services/user_context_provider.dart';

class SigadApp extends StatelessWidget {
  const SigadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserContextProvider(),
      child: Consumer<UserContextProvider>(
        builder: (context, userContext, _) {
          return MaterialApp(
            title: 'SIGAD',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            initialRoute: userContext.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
