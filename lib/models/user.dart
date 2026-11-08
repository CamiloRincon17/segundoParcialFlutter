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
  static const String email = 'admin@correo.com';
  static const String password = 'admin';
  static const String alternatePassword = '123456';
  static const String name = 'camilo';
}


