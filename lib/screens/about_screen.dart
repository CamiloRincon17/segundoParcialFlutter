import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de la App'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Icono representativo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mi Tienda App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Versión 1.0.0 • Examen Segundo Parcial',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Tarjeta: Descripción del Proyecto
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripción General',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Aplicación móvil y web desarrollada en Flutter con arquitectura limpia y modular, diseñada para la consulta, gestión y paginación de productos consumiendo la API de DummyJSON.',
                          style: TextStyle(height: 1.4, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tarjeta: Tecnologías y Características
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Características y Tecnologías',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 20),
                        _buildFeatureRow(
                          Icons.lock_outline,
                          'FlutterSecureStorage',
                          'Almacenamiento seguro cifrado bajo la clave FlutterSecureStorage.token.',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          Icons.route_outlined,
                          'GoRouter',
                          'Navegación declarativa con guards y redirección según estado de sesión.',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          Icons.brightness_6_outlined,
                          'Flutter Riverpod',
                          'Gestor de estado reactivo para cambio fluido de temas (Claro y Oscuro).',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          Icons.sync_alt,
                          'Scroll Infinito y Paginación',
                          'Consumo de API con carga progresiva de 10 en 10 productos.',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          Icons.auto_awesome,
                          'Skeletonizer',
                          'Efecto esqueleto (shimmer) en tarjetas e imágenes mientras se descargan datos.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue.withValues(alpha: 0.15),
          child: Icon(icon, size: 20, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

