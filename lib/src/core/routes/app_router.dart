import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/home_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/login_screen.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/register_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
