import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/home_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/login_screen.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/registration_screen.dart';

// Chaves para navegação sem contexto (útil para testes ou notificações)
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login', // Rota inicial
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegistrationScreen(),
        routes: [
          GoRoute(
            path: 'success',
            name: 'register_success',
            builder: (context, state) => const Scaffold(body: Center(child: Text("Sucesso!"))),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

    ],

    // Tratamento de Erro (Página 404)
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página não encontrada: ${state.uri.toString()}'),
      ),
    ),
  );
}
