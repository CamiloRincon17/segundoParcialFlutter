import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segundoparcialflutter/models/user.dart';

class TokenService {
  static const storage = FlutterSecureStorage();
  static const tokenKey = 'token';

  // Login real contra DummyJSON Auth API (usa cliente Dio sin interceptor)
  static Future<Map<String, dynamic>?> loginWithApi(
      String username, String password) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 10080,
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // Genera un token JWT simulado (fallback para usuarios quemados locales)
  static String generateToken(String email, {String? name, String? avatarUrl}) {
    final displayName = name ?? HardcodedData.getNameForEmail(email);
    final payload = {
      'sub': email,
      'email': email,
      'name': displayName,
      'image': avatarUrl ?? 'https://i.pravatar.cc/150?img=12',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
      'issuer': 'segundoParcialFlutter_auth',
    };
    final jsonStr = jsonEncode(payload);
    final base64Payload = base64Url.encode(utf8.encode(jsonStr));
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$base64Payload.s3cur3_s1gn4tur3';
  }

  // Extrae el usuario directamente del JWT, validando la expiración (exp)
  static User? getUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final normalized = base64Url.normalize(parts[1]);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final json = jsonDecode(decoded) as Map<String, dynamic>;

        // Validación de expiración de token
        if (json['exp'] != null) {
          final expNum = json['exp'] as num;
          final expSeconds = expNum.toInt();
          final expMs = expSeconds < 10000000000 ? expSeconds * 1000 : expSeconds;
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(expMs);

          if (DateTime.now().isAfter(expiryDate)) {
            debugPrint('⚠️ Token expirado: $expiryDate');
            return null;
          }
        }

        final email = json['email'] as String? ?? json['sub'] as String? ?? 'admin@correo.com';

        // Reconstrucción del nombre completo (DummyJSON incluye firstName y lastName)
        final firstName = json['firstName'] as String? ?? '';
        final lastName = json['lastName'] as String? ?? '';
        final fullName = (firstName.isNotEmpty || lastName.isNotEmpty)
            ? '$firstName $lastName'.trim()
            : json['name'] as String? ?? json['username'] as String? ?? email.split('@').first.toUpperCase();

        final avatar = json['image'] as String? ?? 'https://i.pravatar.cc/150?img=12';

        return User(name: fullName, email: email, avatarUrl: avatar);
      }
    } catch (_) {}
    return null;
  }

  // Guarda ÚNICAMENTE con FlutterSecureStorage bajo la clave 'token'
  Future<void> saveToken(String token) async {
    await storage.write(key: tokenKey, value: token);
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

  // Verifica si el token existe y no ha expirado
  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    return getUserFromToken(token) != null;
  }
}
