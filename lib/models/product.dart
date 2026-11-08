class Product {
  final int? id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['thumbnail'] != null && json['thumbnail'].toString().isNotEmpty) {
      imageUrl = json['thumbnail'].toString();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = json['image'].toString();
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      imageUrl = (json['images'] as List).first.toString();
    }

    return Product(
      id: json['id'] as int?,
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      image: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'thumbnail': image,
    };
  }
}
