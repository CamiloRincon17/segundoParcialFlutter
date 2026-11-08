import 'package:flutter/foundation.dart';
import 'package:segundoparcialflutter/models/user.dart';
import 'package:segundoparcialflutter/services/token_service.dart';

export 'package:segundoparcialflutter/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final TokenService _tokenService = TokenService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isCheckingAuth = true;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;

  AuthProvider() {
    _checkInitialAuth();
  }

  // Verifica el token en FlutterSecureStorage al iniciar o recargar
  Future<void> _checkInitialAuth() async {
    _isCheckingAuth = true;
    try {
      final storedToken = await _tokenService.getToken();

      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;
        _user = TokenService.getUserFromToken(storedToken);
      } else {
        // Si el usuario eliminó el token manualmente, limpia el estado
        _token = null;
        _user = null;
      }
    } catch (e) {
      debugPrint('Error en _checkInitialAuth: $e');
      _token = null;
      _user = null;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  // Login: genera el token y lo guarda en FlutterSecureStorage
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
        final userEmail = email.trim();

        // 1. Generar token JWT simulado con los datos en el payload
        final generatedToken = TokenService.generateToken(userEmail);

        // 2. Guardar ÚNICAMENTE el token en FlutterSecureStorage
        await _tokenService.saveToken(generatedToken);

        _token = generatedToken;
        _user = TokenService.getUserFromToken(generatedToken);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error durante login: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Cerrar sesión y eliminar el token de FlutterSecureStorage
  Future<void> logout() async {
    try {
      await _tokenService.clearToken();
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
    _token = null;
    _user = null;
    notifyListeners();
  }
}
