import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:segundoparcialflutter/models/product.dart';
import 'package:segundoparcialflutter/providers/theme_provider.dart';
import 'package:segundoparcialflutter/screens/create_product_screen.dart';
import 'package:segundoparcialflutter/services/api_service.dart';
import 'package:segundoparcialflutter/widgets/app_drawer.dart';
import 'package:segundoparcialflutter/widgets/produc_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  final List<Product> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Detecta cuando el usuario llega al final del scroll para cargar 10 más
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _fetchMoreProducts();
      }
    }
  }

  // Carga inicial (primeros 10 productos)
  Future<void> _fetchInitialProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newItems = await _apiService.getProducts(limit: _pageSize, skip: 0);
      if (!mounted) return;

      setState(() {
        _products.clear();
        _products.addAll(newItems);
        _isLoading = false;
        _hasMore = newItems.length >= _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Carga incremental (los siguientes 10 productos)
  Future<void> _fetchMoreProducts() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextSkip = _products.length;
      final newItems =
          await _apiService.getProducts(limit: _pageSize, skip: nextSkip);

      if (!mounted) return;

      setState(() {
        _products.addAll(newItems);
        _isLoadingMore = false;
        if (newItems.length < _pageSize) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _showProductDetails(Product product) {
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
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
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
                    errorBuilder: (_, _, _) => const Icon(
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
              Text(
                product.description,
                style: const TextStyle(height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _fetchInitialProducts,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchInitialProducts,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const CreateProductScreen(),
            ),
          );
          if (created == true) {
            _fetchInitialProducts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Efecto Esqueleto (Skeleton) mientras carga o si el internet es lento
    if (_isLoading) {
      final skeletonMockList = List.generate(
        6,
        (i) => Product(
          id: i,
          title: 'Cargando nombre del producto...',
          price: 89.99,
          description: 'Descripción provisional del producto mientras se descargan los datos...',
          category: 'CATEGORÍA',
          image: '',
        ),
      );

      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: skeletonMockList.length,
          itemBuilder: (context, index) {
            return ProductCard(product: skeletonMockList[index]);
          },
        ),
      );
    }

    // 2. Si ocurrió un error de red
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Sin conexión o error al conectar con la API',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchInitialProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('No hay productos disponibles.'),
      );
    }

    // 3. Lista con scroll infinito y efecto esqueleto al cargar los siguientes 10
    return ListView.builder(
      controller: _scrollController,
      itemCount: _products.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Al final de la lista, muestra un skeleton card mientras descarga los siguientes 10
        if (index == _products.length) {
          final skeletonNext = Product(
            id: 9999,
            title: 'Cargando más productos...',
            price: 50.00,
            description: 'Obteniendo los siguientes 10 productos...',
            category: 'CARGANDO',
            image: '',
          );
          return Skeletonizer(
            enabled: true,
            child: ProductCard(product: skeletonNext),
          );
        }

        final product = _products[index];
        return ProductCard(
          product: product,
          onTap: () => _showProductDetails(product),
        );
      },
    );
  }
}
