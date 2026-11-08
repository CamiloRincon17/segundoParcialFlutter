import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segundoparcialflutter/models/user.dart';

class TokenService {
  static const storage = FlutterSecureStorage();
  static const tokenKey = 'token';

  // Genera un token JWT simulado con los datos del usuario en el payload
  static String generateToken(String email, {String? name}) {
    final matchedUser = HardcodedData.findByEmail(email);
    final displayName = name ?? (matchedUser != null ? matchedUser.name : email.split('@').first.toUpperCase());

    final payload = {
      'sub': email,
      'name': displayName,
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
      'issuer': 'segundoParcialFlutter_auth',
    };
    final jsonStr = jsonEncode(payload);
    final base64Payload = base64Url.encode(utf8.encode(jsonStr));
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$base64Payload.s3cur3_s1gn4tur3';
  }

  // Extrae el usuario directamente del JWT sin necesitar claves extras en storage
  static User? getUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final normalized = base64Url.normalize(parts[1]);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        final email = json['sub'] as String? ?? 'admin@correo.com';
        final name = json['name'] as String? ?? email.split('@').first.toUpperCase();
        return User(name: name, email: email);
      }
    } catch (_) {}
    return null;
  }

  // Guarda ÚNICAMENTE con FlutterSecureStorage bajo la clave 'token'
  Future<void> saveToken(String token) async {
    // Guarda exclusivamente en FlutterSecureStorage
    await storage.write(key: tokenKey, value: token);

    // Limpia claves antiguas de SharedPreferences / LocalStorage si existían
    try {
      await storage.delete(key: 'user_data');
    } catch (_) {}

    debugPrint('==================================================');
    debugPrint('🔑 FLUTTER_SECURE_STORAGE: token guardado');
    debugPrint(token);
    debugPrint('==================================================');
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
      await storage.delete(key: 'user_data');
    } catch (_) {}
  }

  // Verifica si el token existe
  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
