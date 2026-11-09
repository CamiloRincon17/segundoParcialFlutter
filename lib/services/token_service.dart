import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segundoparcialflutter/models/user.dart';

class TokenService {
  static const storage = FlutterSecureStorage();
  static const tokenKey = 'token';

  // Login real contra DummyJSON Auth API
  static Future<Map<String, dynamic>?> loginWithApi(
      String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://dummyjson.com/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password, 'expiresInMins': 10080}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // Genera un token JWT simulado (fallback para usuarios quemados locales)
  static String generateToken(String email, {String? name}) {
    final displayName = name ?? HardcodedData.getNameForEmail(email);
    final payload = {
      'sub': email,
      'name': displayName,
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now()
          .add(const Duration(days: 7))
          .millisecondsSinceEpoch,
      'issuer': 'segundoParcialFlutter_auth',
    };
    final jsonStr = jsonEncode(payload);
    final base64Payload = base64Url.encode(utf8.encode(jsonStr));
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$base64Payload.s3cur3_s1gn4tur3';
  }

  // Extrae el usuario directamente del JWT
  static User? getUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final normalized = base64Url.normalize(parts[1]);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        final email = json['sub'] as String? ??
            json['email'] as String? ??
            'admin@correo.com';
        final name = json['name'] as String? ??
            json['username'] as String? ??
            email.split('@').first.toUpperCase();
        return User(name: name, email: email);
      }
    } catch (_) {}
    return null;
  }

  // Guarda ÚNICAMENTE con FlutterSecureStorage bajo la clave 'token'
  Future<void> saveToken(String token) async {
    await storage.write(key: tokenKey, value: token);
    // No se imprime el token por seguridad
    debugPrint('🔑 Token guardado en FlutterSecureStorage');
  }

  // Lee ÚNICAMENTE desde FlutterSecureStorage
  Future<String?> getToken() async {
    try {
      return await storage.read(key: tokenKey);
    } catch (_) {
      return null;
    }
  }

  // Elimina de FlutterSecureStorage al cerrar sesión
  Future<void> clearToken() async {
    try {
      await storage.delete(key: tokenKey);
    } catch (_) {}
  }

  // Verifica si el token existe
  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
