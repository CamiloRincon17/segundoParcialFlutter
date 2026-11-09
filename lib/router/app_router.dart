import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segundoparcialflutter/providers/auth_provider.dart';
import 'package:segundoparcialflutter/screens/about_screen.dart';
import 'package:segundoparcialflutter/screens/create_product_screen.dart';
import 'package:segundoparcialflutter/screens/home_screen.dart';
import 'package:segundoparcialflutter/screens/login_screen.dart';
import 'package:segundoparcialflutter/screens/profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String createProduct = '/create-product';
  static const String profile = '/profile';
  static const String about = '/about';
}

// Router como Riverpod provider — se recrea cuando cambia el estado de auth
final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (BuildContext context, GoRouterState state) {
      // Mientras inicializa, no redirigir
      if (authAsync.isLoading || authAsync.value?.isInitializing == true) {
        return null;
      }

      final isLoggedIn = authAsync.value?.isAuthenticated ?? false;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isLoggingIn) return AppRoutes.login;
      if (isLoggedIn && isLoggingIn) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final isLoggedIn =
              ref.read(authProvider).value?.isAuthenticated ?? false;
          return isLoggedIn ? AppRoutes.home : AppRoutes.login;
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.createProduct,
        name: 'create_product',
        builder: (context, state) => const CreateProductScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
});
