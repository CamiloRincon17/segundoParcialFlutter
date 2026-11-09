import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segundoparcialflutter/models/product.dart';
import 'package:segundoparcialflutter/services/api_service.dart';

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool hasLoadMoreError;
  final String? errorMessage;

  const ProductsState({
    this.products = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.hasLoadMoreError = false,
    this.errorMessage,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? hasLoadMoreError,
    String? errorMessage,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      hasLoadMoreError: clearLoadMoreError
          ? false
          : (hasLoadMoreError ?? this.hasLoadMoreError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProductsNotifier extends Notifier<ProductsState> {
  static const int _pageSize = 10;
  ApiService get _api => ref.read(apiServiceProvider);

  // Contador exclusivo para la API (no se altera al agregar productos locales)
  int _apiSkip = 0;

  @override
  ProductsState build() {
    _apiSkip = 0;
    Future.microtask(fetchInitial);
    return const ProductsState(isLoading: true);
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLoadMoreError: true,
    );
    try {
      final items = await _api.getProducts(limit: _pageSize, skip: 0);
      _apiSkip = items.length;
      state = ProductsState(
        products: items,
        isLoading: false,
        hasMore: items.length >= _pageSize,
      );
    } catch (e) {
      _apiSkip = 0;
      state = ProductsState(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        hasMore: false,
      );
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true, clearLoadMoreError: true);
    try {
      final items = await _api.getProducts(limit: _pageSize, skip: _apiSkip);
      _apiSkip += items.length;
      state = state.copyWith(
        products: [...state.products, ...items],
        isLoadingMore: false,
        hasMore: items.length >= _pageSize,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        hasLoadMoreError: true,
      );
    }
  }

  // Agrega el producto nuevo creado al inicio sin desfasar el skip de la API
  void addProductLocally(Product product) {
    state = state.copyWith(products: [product, ...state.products]);
  }
}

final productsProvider =
    NotifierProvider<ProductsNotifier, ProductsState>(ProductsNotifier.new);
