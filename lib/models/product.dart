import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // Factory constructor for creating a new Product instance from JSON
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  // Method to convert Product instance to JSON
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
