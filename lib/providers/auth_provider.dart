import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segundoparcialflutter/models/user.dart';
import 'package:segundoparcialflutter/services/token_service.dart';

export 'package:segundoparcialflutter/models/user.dart';

// Estado de autenticación
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final bool isInitializing;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.isInitializing = true,
  });

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    bool? isInitializing,
    bool clearUser = false,
    bool clearToken = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
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
        return AuthState(
          user: user,
          token: storedToken,
          isInitializing: false,
        );
      }
    } catch (_) {}
    return const AuthState(isInitializing: false);
  }

  // Login: primero intenta contra DummyJSON API, si falla valida localmente
  Future<bool> login(String emailOrUsername, String password) async {
    final prev = state.value ?? const AuthState(isInitializing: false);
    state = AsyncData(prev.copyWith(isLoading: true, isInitializing: false));

    try {
      // 1. Intenta login con DummyJSON Auth API
      final apiResult =
          await TokenService.loginWithApi(emailOrUsername, password);

      if (apiResult != null) {
        final apiToken = apiResult['accessToken']?.toString() ??
            apiResult['token']?.toString() ?? '';
        final apiName = apiResult['firstName'] != null
            ? '${apiResult['firstName']} ${apiResult['lastName'] ?? ''}'.trim()
            : apiResult['username']?.toString() ?? emailOrUsername;
        final apiEmail = apiResult['email']?.toString() ?? emailOrUsername;

        final token = apiToken.isNotEmpty
            ? apiToken
            : TokenService.generateToken(apiEmail, name: apiName);

        await _tokenService.saveToken(token);

        final user = User(name: apiName, email: apiEmail);
        state = AsyncData(AuthState(
          user: user,
          token: token,
          isLoading: false,
          isInitializing: false,
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
          isInitializing: false,
        ));
        return true;
      }
    } catch (_) {}

    state = AsyncData(prev.copyWith(isLoading: false, isInitializing: false));
    return false;
  }

  Future<void> logout() async {
    await _tokenService.clearToken();
    state = const AsyncData(AuthState(isInitializing: false));
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
