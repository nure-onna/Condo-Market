class Product {
  final int id;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.createdAt,
  });

  // Construtor de fábrica para criar uma instância de Product a partir de um JSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Método para converter o objeto em um JSON para ser inserido no Supabase.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
