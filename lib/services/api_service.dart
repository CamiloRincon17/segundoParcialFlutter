import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segundoparcialflutter/models/product.dart';
import 'package:segundoparcialflutter/providers/auth_provider.dart';
import 'package:segundoparcialflutter/services/auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  dio.interceptors.add(AuthInterceptor(
    onUnauthorized: () => ref.read(authProvider.notifier).logout(),
  ));
  return dio;
});

final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(ref.watch(dioProvider)));

class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  Future<List<Product>> getProducts({int limit = 10, int skip = 0}) async {
    try {
      final res = await _dio.get(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      final list = (res.data['products'] as List?) ?? [];
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Error inesperado');
    }
  }

  Future<Product?> createProduct(Product product) async {
    try {
      final res = await _dio.post('/products/add', data: product.toJson());
      return Product.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }
}
