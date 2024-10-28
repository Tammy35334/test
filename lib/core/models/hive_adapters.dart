import 'package:hive/hive.dart';
import 'product.dart';

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    return Product(
      id: reader.read(),
      name: reader.read(),
      storePrices: Map<String, double>.from(reader.read()),
      category: reader.read(),
      imageUrl: reader.read(),
      isFavorite: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.storePrices);
    writer.write(obj.category);
    writer.write(obj.imageUrl);
    writer.write(obj.isFavorite);
  }
}
