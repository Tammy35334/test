import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final Map<String, double> storePrices;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final String imageUrl;
  
  @HiveField(5)
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.storePrices,
    required this.category,
    required this.imageUrl,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      storePrices: Map<String, double>.from(json['store_prices'] as Map),
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'store_prices': storePrices,
      'category': category,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
    };
  }
}
