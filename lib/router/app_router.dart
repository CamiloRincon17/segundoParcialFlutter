import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segundoparcialflutter/providers/auth_provider.dart';
import 'package:segundoparcialflutter/screens/about_screen.dart';
import 'package:segundoparcialflutter/screens/create_product_screen.dart';
import 'package:segundoparcialflutter/screens/home_screen.dart';
import 'package:segundoparcialflutter/screens/login_screen.dart';
import 'package:segundoparcialflutter/screens/profile_screen.dart';
import 'package:segundoparcialflutter/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String createProduct = '/create-product';
  static const String profile = '/profile';
  static const String about = '/about';
}

// Escucha cambios en authProvider y refresca GoRouter sin destruirlo
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(
      authProvider,
      (previous, next) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authProvider);

    // Mientras se verifica el token inicial, mantenerse en /splash
    if (authAsync.isLoading) {
      return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final isLoggedIn = authAsync.value?.isAuthenticated ?? false;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;
    final isSplash = state.matchedLocation == AppRoutes.splash;

    // Si no tiene sesión activa, redirigir a login
    if (!isLoggedIn) {
      return isLoggingIn ? null : AppRoutes.login;
    }

    // Si ya tiene sesión activa y está en login o splash, llevar a home
    if (isLoggingIn || isSplash) {
      return AppRoutes.home;
    }

    return null;
  }
}

final routerNotifierProvider =
    Provider<RouterNotifier>((ref) => RouterNotifier(ref));

// El router se instancia una sola vez y no se destruye en cada cambio de estado
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
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
