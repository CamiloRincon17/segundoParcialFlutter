class User {
  final String name;
  final String email;
  final String avatarUrl;

  const User({
    required this.name,
    required this.email,
    this.avatarUrl = 'https://i.pravatar.cc/150?img=12',
  });
}

class HardcodedData {
  // Usuario 1
  static const String email = 'admin@correo.com';
  static const String password = 'admin';
  static const String alternatePassword = '123456';
  static const String name = 'camilo';

  // Usuario 2
  static const String email2 = 'usuario2@correo.com';
  static const String password2 = '123456';
  static const String name2 = 'Uriel Mauricio';

  // Obtener el nombre del usuario según su correo
  static String getNameForEmail(String inputEmail) {
    if (inputEmail.trim().toLowerCase() == email2.toLowerCase()) {
      return name2;
    }
    return name;
  }

  // Validar si coincide con las credenciales de algún usuario
  static bool validate(String inputEmail, String inputPassword) {
    final e = inputEmail.trim().toLowerCase();
    final p = inputPassword.trim();
    if (e == email.toLowerCase() && (p == password || p == alternatePassword)) {
      return true;
    }
    if (e == email2.toLowerCase() && p == password2) {
      return true;
    }
    return false;
  }
}
