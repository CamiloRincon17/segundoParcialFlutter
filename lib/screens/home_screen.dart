import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:segundoparcialflutter/models/product.dart';
import 'package:segundoparcialflutter/providers/products_provider.dart';
import 'package:segundoparcialflutter/providers/theme_provider.dart';
import 'package:segundoparcialflutter/router/app_router.dart';
import 'package:segundoparcialflutter/widgets/app_drawer.dart';
import 'package:segundoparcialflutter/widgets/produc_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      ref.read(productsProvider.notifier).fetchMore();
    }
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: 180,
                  color: Colors.white,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(product.category),
                    backgroundColor:
                        Theme.of(ctx).colorScheme.primaryContainer,
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Descripción:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(product.description,
                  style: const TextStyle(height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
            onPressed: () =>
                ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () =>
                ref.read(productsProvider.notifier).fetchInitial(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(productsProvider.notifier).fetchInitial(),
        child: _buildBody(context, productsState),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Ambas vías (FAB y drawer) usan context.push<Product>
          final created =
              await context.push<Product>(AppRoutes.createProduct);
          if (created != null) {
            ref
                .read(productsProvider.notifier)
                .addProductLocally(created);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    // 1. Skeleton inicial
    if (state.isLoading) {
      final mockList = List.generate(
        6,
        (i) => Product(
          id: i,
          title: 'Cargando nombre del producto...',
          price: 89.99,
          description: 'Descripción provisional...',
          category: 'CATEGORÍA',
          image: '',
        ),
      );
      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockList.length,
          itemBuilder: (_, i) => ProductCard(product: mockList[i]),
        ),
      );
    }

    // 2. Error con RefreshIndicator funcional (ListView para que el pull funcione)
    if (state.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 60, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  'Sin conexión o error al conectar con la API',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(productsProvider.notifier).fetchInitial(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 3. Lista vacía (con pull-to-refresh funcional)
    if (state.products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text('No hay productos disponibles.')),
        ],
      );
    }

    // 4. Lista con scroll infinito + skeleton al cargar más
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.products.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.products.length) {
          // Skeleton card mientras carga los siguientes 10
          final skeleton = Product(
            id: 9999,
            title: 'Cargando más productos...',
            price: 50.00,
            description: 'Obteniendo los siguientes 10 productos...',
            category: 'CARGANDO',
            image: '',
          );
          return Skeletonizer(
            enabled: true,
            child: ProductCard(product: skeleton),
          );
        }
        final product = state.products[index];
        return ProductCard(
          product: product,
          onTap: () => _showProductDetails(context, product),
        );
      },
    );
  }
}
