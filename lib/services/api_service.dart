import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segundoparcialflutter/models/product.dart';

class ApiService {
  // DummyJSON cuenta con casi 200 productos y soporte nativo de paginación
  static const String baseUrl = 'https://dummyjson.com';

  // Obtener productos de 10 en 10 usando paginación (limit y skip)
  Future<List<Product>> getProducts({int limit = 10, int skip = 0}) async {
    final url = Uri.parse('$baseUrl/products?limit=$limit&skip=$skip');

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        return productsJson.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  // Crear un producto nuevo
  Future<bool> createProduct(Product product) async {
    final url = Uri.parse('$baseUrl/products/add');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(product.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
