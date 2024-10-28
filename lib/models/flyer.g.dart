// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flyer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlyerAdapter extends TypeAdapter<Flyer> {
  @override
  final int typeId = 1;

  @override
  Flyer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flyer(
      storeId: fields[0] as int,
      storeName: fields[1] as String,
      province: fields[2] as String,
      flyerImages: (fields[3] as List).cast<String>(),
      lastUpdated: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Flyer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.storeId)
      ..writeByte(1)
      ..write(obj.storeName)
      ..writeByte(2)
      ..write(obj.province)
      ..writeByte(3)
      ..write(obj.flyerImages)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlyerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
