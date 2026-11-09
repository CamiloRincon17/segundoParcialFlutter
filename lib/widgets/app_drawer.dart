import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segundoparcialflutter/models/product.dart';
import 'package:segundoparcialflutter/providers/auth_provider.dart';
import 'package:segundoparcialflutter/providers/products_provider.dart';
import 'package:segundoparcialflutter/providers/theme_provider.dart';
import 'package:segundoparcialflutter/router/app_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).value;
    final user = authState?.user;
    final isDarkMode = ref.watch(themeProvider);

    final userName = user?.name ?? 'Invitado';
    final userEmail = user?.email ?? 'invitado@ejemplo.com';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio / Productos'),
            onTap: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.home);
            },
          ),

          // Crear producto: igual que el FAB, usa context.push<Product>
          ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: const Text('Crear Producto'),
            onTap: () async {
              Navigator.of(context).pop();
              final created =
                  await context.push<Product>(AppRoutes.createProduct);
              if (created != null) {
                ref
                    .read(productsProvider.notifier)
                    .addProductLocally(created);
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            subtitle: const Text('Ver datos y token seguro'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.profile);
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de la App'),
            subtitle: const Text('Información del sistema'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.about);
            },
          ),

          const Divider(),

          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.amber : Colors.blue,
            ),
            title: const Text('Tema'),
            subtitle: Text(isDarkMode ? 'Modo Oscuro' : 'Modo Claro'),
            value: isDarkMode,
            onChanged: (_) =>
                ref.read(themeProvider.notifier).toggleTheme(),
          ),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
