// lib/models/product.dart

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@HiveType(typeId: 0) // Unique typeId for Hive
@JsonSerializable()
class Product extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String imageUrl; // Added imageUrl field

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl, // Initialize imageUrl
  });

  // From JSON
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
