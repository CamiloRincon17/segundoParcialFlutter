import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:segundoparcialflutter/providers/auth_provider.dart';
import 'package:segundoparcialflutter/screens/about_screen.dart';
import 'package:segundoparcialflutter/screens/create_product_screen.dart';
import 'package:segundoparcialflutter/screens/home_screen.dart';
import 'package:segundoparcialflutter/screens/login_screen.dart';
import 'package:segundoparcialflutter/screens/profile_screen.dart';
import 'package:segundoparcialflutter/services/token_service.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String createProduct = '/create-product';
  static const String profile = '/profile';
  static const String about = '/about';
}

final storage = TokenService.storage;

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) async {
      // Lee directamente desde FlutterSecureStorage con la clave 'token'
      String? token;
      try {
        token = await storage.read(key: 'token');
      } catch (_) {}

      final bool loggedIn = token != null && token.isNotEmpty;
      final bool loggingIn = state.matchedLocation == AppRoutes.login;

      // Si no tiene token y no está en /login, enviarlo a /login
      if (!loggedIn) {
        return loggingIn ? null : AppRoutes.login;
      }

      // Si ya tiene token y está en /login, enviarlo a /home
      if (loggingIn) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) async {
          String? token;
          try {
            token = await storage.read(key: 'token');
          } catch (_) {}
          return (token != null && token.isNotEmpty)
              ? AppRoutes.home
              : AppRoutes.login;
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
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );
}
