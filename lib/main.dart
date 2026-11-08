import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:segundoparcialflutter/providers/auth_provider.dart';
import 'package:segundoparcialflutter/providers/theme_provider.dart';
import 'package:segundoparcialflutter/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = createRouter(auth);
  }

  @override
  Widget build(BuildContext context) {
    // Escucha el modo de tema desde Riverpod
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'App Segundo Parcial',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,

      // Modo de tema controlado con Riverpod
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Tema Claro
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
        ),
      ),

      // Tema Oscuro
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
        ),
      ),
    );
  }
}
