import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class VoompSellersApp extends StatelessWidget {
  const VoompSellersApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ouve as mudanças no ThemeController
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Voomp Sellers',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,

          // Configuração dos Temas
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,
        );
      },
    );
  }
}
