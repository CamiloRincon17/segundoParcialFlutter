import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segundoparcialflutter/models/user.dart';
import 'package:segundoparcialflutter/providers/products_provider.dart';
import 'package:segundoparcialflutter/services/token_service.dart';

export 'package:segundoparcialflutter/models/user.dart';

// Estado de sesión
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
  });

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    bool clearUser = false,
    bool clearToken = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  final _tokenService = TokenService();

  @override
  Future<AuthState> build() async {
    return _checkInitialAuth();
  }

  Future<AuthState> _checkInitialAuth() async {
    try {
      final storedToken = await _tokenService.getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        final user = TokenService.getUserFromToken(storedToken);
        if (user != null) {
          return AuthState(
            user: user,
            token: storedToken,
          );
        } else {
          // Token expirado o inválido: limpiarlo
          await _tokenService.clearToken();
        }
      }
    } catch (_) {}
    return const AuthState();
  }

  // Login: intenta contra DummyJSON API primero; si falla, valida usuarios locales
  Future<bool> login(String emailOrUsername, String password) async {
    final prev = state.value ?? const AuthState();
    state = AsyncData(prev.copyWith(isLoading: true));

    try {
      // 1. Intenta login con DummyJSON Auth API
      final apiResult =
          await TokenService.loginWithApi(emailOrUsername, password);

      if (apiResult != null) {
        final apiToken = apiResult['accessToken']?.toString() ??
            apiResult['token']?.toString() ?? '';
        final firstName = apiResult['firstName']?.toString() ?? '';
        final lastName = apiResult['lastName']?.toString() ?? '';
        final fullName = (firstName.isNotEmpty || lastName.isNotEmpty)
            ? '$firstName $lastName'.trim()
            : apiResult['username']?.toString() ?? emailOrUsername;
        final apiEmail = apiResult['email']?.toString() ?? emailOrUsername;
        final avatar = apiResult['image']?.toString() ?? 'https://i.pravatar.cc/150?img=12';

        final token = apiToken.isNotEmpty
            ? apiToken
            : TokenService.generateToken(apiEmail, name: fullName, avatarUrl: avatar);

        await _tokenService.saveToken(token);

        final user = User(name: fullName, email: apiEmail, avatarUrl: avatar);
        state = AsyncData(AuthState(
          user: user,
          token: token,
          isLoading: false,
        ));
        return true;
      }

      // 2. Fallback: validar contra credenciales quemadas locales
      final isValid = HardcodedData.validate(emailOrUsername, password);
      if (isValid) {
        final name = HardcodedData.getNameForEmail(emailOrUsername);
        final token = TokenService.generateToken(emailOrUsername, name: name);
        await _tokenService.saveToken(token);

        final user = User(name: name, email: emailOrUsername);
        state = AsyncData(AuthState(
          user: user,
          token: token,
          isLoading: false,
        ));
        return true;
      }
    } catch (_) {}

    state = AsyncData(prev.copyWith(isLoading: false));
    return false;
  }

  Future<void> logout() async {
    await _tokenService.clearToken();
    // Reinicia el catálogo y elimina los productos creados localmente
    ref.invalidate(productsProvider);
    state = const AsyncData(AuthState());
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
