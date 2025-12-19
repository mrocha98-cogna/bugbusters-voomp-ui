import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/account/presentation/pages/my_account_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/home_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/login_screen.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/pages/register_screen.dart';
import 'package:voomp_sellers_rebranding/src/core/features/finance/presentation/pages/financial_statement_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_model.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/presentation/pages/create_product_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/presentation/pages/product_details_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/presentation/pages/product_list_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final token = await DatabaseHelper.instance.getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, _) => '/home',
      ),
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
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: '/create-product',
        builder: (context, state) => const CreateProductPage(),
      ),
      GoRoute(
        path: '/product-details/:id', // Mantemos o ID na URL para deep linking se precisar
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';

          final product = state.extra as ProductModel?;

          return ProductDetailsPage(
            productId: productId,
            product: product, // Passamos o objeto (pode ser null se acessado via URL direta)
          );
        },
      ),
      GoRoute(
        path: '/financial-statement',
        builder: (context, state) => const FinancialStatementPage(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const MyAccountPage(),
      ),
    ],
  );
}
