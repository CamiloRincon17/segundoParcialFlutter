import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segundoparcialflutter/models/product.dart';
import 'package:segundoparcialflutter/services/api_service.dart';

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const ProductsState({
    this.products = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProductsNotifier extends Notifier<ProductsState> {
  static const int _pageSize = 10;
  final _api = ApiService();

  @override
  ProductsState build() {
    Future.microtask(fetchInitial);
    return const ProductsState(isLoading: true);
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.getProducts(limit: _pageSize, skip: 0);
      state = ProductsState(
        products: items,
        isLoading: false,
        hasMore: items.length >= _pageSize,
      );
    } catch (e) {
      state = ProductsState(
        isLoading: false,
        errorMessage: e.toString(),
        hasMore: false,
      );
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final skip = state.products.length;
      final items = await _api.getProducts(limit: _pageSize, skip: skip);
      state = state.copyWith(
        products: [...state.products, ...items],
        isLoadingMore: false,
        hasMore: items.length >= _pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // Agrega el producto localmente al inicio (DummyJSON no persiste realmente)
  void addProductLocally(Product product) {
    state = state.copyWith(products: [product, ...state.products]);
  }
}

final productsProvider =
    NotifierProvider<ProductsNotifier, ProductsState>(ProductsNotifier.new);

